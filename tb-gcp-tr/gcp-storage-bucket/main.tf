# Copyright 2020 The Tranquility Base Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "random_id" "default" {
  byte_length = 4
}

resource "google_storage_bucket" "bucket" {
  name               = "${var.name}-${random_id.default.hex}"
  project            = var.project_id
  location           = var.location
  storage_class      = var.storage_class
  bucket_policy_only = var.bucket_policy_only
  labels             = var.labels
  force_destroy      = var.force_destroy

  depends_on = [
    var.buckets_depend_on
  ]

  versioning {
    enabled = var.versioning
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy == null ? [] : [var.retention_policy]
    content {
      is_locked        = var.retention_policy.is_locked
      retention_period = var.retention_policy.retention_period
    }
  }

  dynamic "encryption" {
    for_each = var.encryption == null ? [] : [var.encryption]
    content {
      default_kms_key_name = var.encryption.default_kms_key_name
    }
  }

  dynamic "website" {
    for_each = var.website_main_page_suffix == null ? [] : [var.website_main_page_suffix]
    content {
      main_page_suffix = var.website_main_page_suffix
      not_found_page   = var.website_not_found_page
    }
  }

  dynamic "logging" {
    for_each = var.log_bucket == null ? [] : [var.log_bucket]
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "storage_class", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }
}

resource "google_storage_bucket_iam_member" "members" {
  for_each = {
    for m in var.iam_members : "${m.role} ${m.member}" => m
  }
  bucket = google_storage_bucket.bucket.name
  role   = each.value.role
  member = each.value.member
}

resource "google_storage_bucket_iam_binding" "admins" {
  count  = var.set_admin_roles ? 1 : 0
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  members = compact(
    concat(
      var.admins,
      split(
        ",",
        lookup(var.bucket_admins, var.name, ""),
      ),
    ),
  )
}

resource "google_storage_bucket_iam_binding" "creators" {
  count  = var.set_creator_roles ? 1 : 0
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectCreator"
  members = compact(
    concat(
      var.creators,
      split(
        ",",
        lookup(var.bucket_creators, var.name, ""),
      ),
    ),
  )
}

resource "google_storage_bucket_iam_binding" "viewers" {
  count  = var.set_viewer_roles ? 1 : 0
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  members = compact(
    concat(
      var.viewers,
      split(
        ",",
        lookup(var.bucket_viewers, var.name, ""),
      ),
    ),
  )
}
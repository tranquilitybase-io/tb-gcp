# Copyright 2019 The Tranquility Base Authors
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

#CREATE-AUDIT-LOGGING

resource "random_id" "logging" {
  byte_length = var.randomidlen
}

###create the log bucket
resource "google_storage_bucket" "audit_log_bucket" {
  project  = var.logging_project_id
  name     = join("", [var.bucketprefix, random_id.logging.hex])
  location = var.region

  retention_policy {
    is_locked = var.bucketlock
    retention_period = var.retentionperiod
  }

  lifecycle_rule {
    condition {
      age = var.changestorageage
    }
    action {
      type          = "SetStorageClass"
      storage_class = var.storageclass
    }
  }

  lifecycle_rule {
    condition {
      age = var.deleteage
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    fuction = var.labelfuction
  }
}

###create sink to push logs to bucket in the logging project
resource "google_logging_folder_sink" "audit_log_sink" {
  folder = var.root_id
  name    = var.sinkname

  # export to log bucket
  destination = "storage.googleapis.com/${google_storage_bucket.audit_log_bucket.name}"
}  

###give service account permissions to bucket
resource "google_storage_bucket_iam_binding" "bucket_audit_log_writer" {
  bucket = google_storage_bucket.audit_log_bucket.name
  members = [google_logging_folder_sink.audit_log_sink.writer_identity]
  role = "roles/storage.objectCreator"
}

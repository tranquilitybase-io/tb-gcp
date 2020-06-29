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
  byte_length = 4
}

###create the log bucket
resource "google_storage_bucket" "log-bucket" {
  project  = var.shared_telemetry_project_id
  name     = "audit-log-bucket-${random_id.logging.hex}"
  location = var.region

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
    purpose = "sends_to_collect_admin_read_data_write_data_read_audit_logs"
  }
}

###create sink to push logs to bucket in telemtry project
resource "google_logging_folder_sink" "audit_log_sink" {
  folder = var.root_id
  name    = "audit_log_sink"

  # export to log bucket
  destination = "storage.googleapis.com/${google_storage_bucket.log-bucket.name}"

  # Use a unique writer (creates a unique service account used for writing)
  unique_writer_identity = true
}

#Gives the log writer permissions to bucket
resource "google_project_iam_binding" "log-writer" {
  project = var.shared_telemetry_project_id
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.audit_log_sink.writer_identity,
  ]
}





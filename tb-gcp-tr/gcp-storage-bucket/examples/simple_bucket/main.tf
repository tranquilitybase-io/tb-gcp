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

# create a bucket for the access & storage logs
module "gcs_bucket_access_storage_logs" {
  source = "../.."

  name        = var.gcs_log_bucket_name
  project_id  = module.shared_projects.shared_telemetry_id
  iam_members = var.iam_members_bindings
}

# create the main bucket and use the other bucket for its access logs
module "gcs_bucket" {
  source = "../.."

  name       = "a-globally-unique-name-zi01farm"
  project_id = module.shared_projects.shared_telemetry_id
  log_bucket = module.gcs_bucket_access_storage_logs.name

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age        = 365
      with_state = "ANY"
    }
  }]
}
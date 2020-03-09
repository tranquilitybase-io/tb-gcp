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

# create compute service account for bastion host
resource "google_service_account" "bastion" {
  account_id   = var.bastion_service_account
  display_name = "${var.bastion_service_account} service account"
  project      = var.bastion_project_id
}

# assign default service agent permission in service project
resource "google_project_iam_member" "bastion_serviceAgent" {
  project = var.bastion_project_id
  role    = "roles/compute.serviceAgent"
  member  = format("serviceAccount:%s", google_service_account.bastion.email)
}


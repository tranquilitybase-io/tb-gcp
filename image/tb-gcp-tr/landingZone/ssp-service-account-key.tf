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

#CREATE-SERVICE-ACCOUNT
resource "google_service_account" "activator" {
  account_id   = "activator-dev-sa"
  display_name = "activator-dev-sa"
  project = "${module.shared_projects.shared_ssp_id}"
}

locals {
  service_account_name = "serviceAccount:${google_service_account.activator.account_id}@${module.shared_projects.shared_ssp_id}.iam.gserviceaccount.com"
}

// add count for all roles / extreact to separate file ? remember about tags
#ADD-POLICY-TO-SERVICE-ACCOUNT
resource "google_folder_iam_member" "sa-folder-admin-role" {
  count = "${length(var.ssp_iam_service_account_roles)}"
  folder  = "${module.folder_structure.tbase_id}"
  role    = "${element(var.ssp_iam_service_account_roles, count.index)}"
  member  = "${local.service_account_name}"
  depends_on = ["google_service_account.activator"]
}

resource "google_folder_iam_member" "xpnbinding" {
  folder = "${module.folder_structure.tbase_id}"
  member = "${local.service_account_name}"
  role = "roles/compute.admin"
}

#ADD-POLICY-TO-BILLING-ACCOUNT
resource "google_billing_account_iam_member" "ba-billing-account-user" {
  billing_account_id = "${var.billing_account_id}"
  role = "roles/billing.admin"
  member = "${local.service_account_name}"
}

resource "google_service_account_key" "mykey" {
  service_account_id = "${google_service_account.activator.name}"
  depends_on = ["google_service_account.activator"]
}

resource "local_file" "ssp_service_account_key" {
  content = "${base64decode(google_service_account_key.mykey.private_key)}"
  filename = "/tmp/tb-gcp-tr/bootstrap/ssp-service-account-config.json"
}
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

# service account used to access the CloudSQL database via the cloud proxy
resource "google_service_account" "sql-proxy-sa" {
  account_id   = "${var.cloudsql_proxy_sa_name}"
  display_name = "${var.cloudsql_proxy_sa_name} service account"
  project      = "${data.google_project.host-project.project_id}"

  //depends_on = ["google_project_services.project"]
}

# assign default service agent permission in service project
resource "google_project_iam_member" "sql-proxy-client" {
  project = "${data.google_project.host-project.project_id}"
  role    = "roles/cloudsql.client"
  member  = "${format("serviceAccount:%s", google_service_account.sql-proxy-sa.email)}"
}

resource "google_service_account_key" "sql-proxy-sa-key" {
  service_account_id = "${google_service_account.sql-proxy-sa.name}"
}

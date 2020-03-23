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

resource "google_project_services" "project" {
  project = var.host_project_id
  services = [
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "recommender.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

/*
resource "google_project_services" "ec_project" {
  project = "${var.ec_project_id}"
  services   = ["compute.googleapis.com", "oslogin.googleapis.com", "container.googleapis.com"]
  depends_on = ["google_project_services.project"]
}
*/

resource "google_project_service" "bastion-iap" {
  project = var.bastion_project_id
  service = "iap.googleapis.com"
  depends_on = ["google_project_services.project"]
}
resource "google_project_service" "bastion-recommender" {
  project = var.bastion_project_id
  service = "recommender.googleapis.com"
  depends_on = ["google_project_services.project"]
}

resource "google_project_services" "project_shared" {
  count   = var.service_projects_number
  project = var.service_project_ids[count.index]
  services = [
    "appengine.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "datastore.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "recommender.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]
  depends_on = [google_project_services.project]
}


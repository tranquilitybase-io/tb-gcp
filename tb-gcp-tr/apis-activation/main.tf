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

locals {
  host_project_apis = [
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
    "dns.googleapis.com",
  ]
  service_project_apis = [
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
  bastion_project_apis = [
    "recommender.googleapis.com",
    "iap.googleapis.com",
    "container.googleapis.com",
    "serviceusage.googleapis.com"
  ]
  telemetry_project_apis = [
    "cloudkms.googleapis.com"
  ]
}


resource "google_project_service" "host-project" {
  project                    = var.host_project_id
  for_each                   = toset(local.host_project_apis)
  service                    = each.value
  disable_dependent_services = true
}

resource "google_project_service" "eagle_console" {
  project                    = var.eagle_console_project_id
  for_each                   = toset(local.service_project_apis)
  service                    = each.value
  disable_dependent_services = true
  depends_on                 = [google_project_service.host-project]

}

resource "google_project_service" "bastion" {
  project                    = var.bastion_project_id
  for_each                   = toset(local.bastion_project_apis)
  service                    = each.value
  disable_dependent_services = true
  depends_on                 = [google_project_service.host-project]
}

resource "google_project_service" "telemetry" {
  project                    = var.telemetry_project_id
  for_each                   = toset(local.telemetry_project_apis)
  service                    = each.value
  disable_dependent_services = true
  depends_on                 = [google_project_service.host-project]
}




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
}


module "host-project" {
  project_id = var.shared_ec_id
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "2.1.3"

  activate_apis = local.host_project_apis

}

module "shared_secrets" {
  project_id = var.shared_ec_id
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "2.1.3"

  activate_apis = local.service_project_apis

}

module "shared_itsm" {
  project_id = var.shared_ec_id
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "2.1.3"

  activate_apis = local.service_project_apis

}

module "shared_ec" {
  project_id = var.shared_ec_id
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "2.1.3"

  activate_apis = local.service_project_apis

}

module "bastion" {
  project_id = var.shared_ec_id
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "2.1.3"

  activate_apis = ["iap.googleapis.com", "recommender.googleapis.com"]
}

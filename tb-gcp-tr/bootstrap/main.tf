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

provider "google" {
  region = "${var.region}"
  zone = "${var.region_zone}"
}

#CREATE-BOOTSTRAP-PROJECT
locals {
  tb_discriminator_suffix = "${var.tb_discriminator == "" ? "" : "-${lower(var.tb_discriminator)}"}"
}

resource "random_id" "project" {
  byte_length = 4
}

resource "google_project" "bootstrap-res" {
  auto_create_network = false
  name = "bootstrap${local.tb_discriminator_suffix}"
  project_id = "bootstrap${local.tb_discriminator_suffix}-${random_id.project.hex}"
  folder_id  = "${var.folder_id}"
  billing_account = "${var.billing_account_id}"
}

#ENABLE-PROJECT-APIS
resource "google_project_services" "bootstrap_project_apis" {
  project = "${google_project.bootstrap-res.project_id}"
  services = [
    "appengine.googleapis.com",
    "bigquery-json.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "datastore.googleapis.com",
    "iap.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

#CREATE-SERVICE-ACCOUNT
resource "google_service_account" "bootstrap-sa-res" {
  account_id   = "bootstrap${local.tb_discriminator_suffix}-sa"
  display_name = "bootstrap${local.tb_discriminator_suffix}-sa"
  project = "${google_project.bootstrap-res.project_id}"
  depends_on = ["google_project.bootstrap-res"]
}

locals {
  service_account_name = "serviceAccount:${google_service_account.bootstrap-sa-res.account_id}@${google_project.bootstrap-res.project_id}.iam.gserviceaccount.com"
}

resource "google_folder_iam_member" "sa-folder-admin-role" {
  count = "${length(var.main_iam_service_account_roles)}"
  folder  = "folders/${var.folder_id}"
  role    = "${element(var.main_iam_service_account_roles, count.index)}"
  member  = "${local.service_account_name}"
  depends_on = ["google_service_account.bootstrap-sa-res"]
}

resource "google_project_iam_member" "xpn" {
  project = "${google_project.bootstrap-res.project_id}"
  role    = "roles/compute.admin"
  member  = "${local.service_account_name}"
  depends_on = ["google_service_account.bootstrap-sa-res"]
}
#ADD-POLICY-TO-BILLING-ACCOUNT
resource "google_billing_account_iam_member" "sa-billing-account-user" {
  billing_account_id = "${var.billing_account_id}"
  role = "roles/billing.admin"
  member = "${local.service_account_name}"
  depends_on = ["google_service_account.bootstrap-sa-res"]
}

#CREATE-TERRAFORM-STATE-BUCKET
resource "google_storage_bucket" "terraform-state-bucket-res" {
  project = "${google_project.bootstrap-res.project_id}"
  name     = "terraform-state-bucket-${random_id.project.hex}"
  location = "EU"
  depends_on = ["google_project_services.bootstrap_project_apis"]
}

#CREATE-BOOTSTRAP-TERRAFORM-SERVER
resource "google_compute_instance" "bootstrap_terraform_server" {
  project = "${google_project.bootstrap-res.project_id}"
  name = "${var.terraform_server_name}"
  machine_type = "${var.terraform_server_machine_type}"

  boot_disk {
    initialize_params {
      image = "${var.bootstrap_host_disk_image}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.bootstrap_subnet.self_link}"
  }

  metadata_startup_script = "${data.template_file.startup-script.rendered}"

  service_account {
    email = "${google_service_account.bootstrap-sa-res.email}"
    scopes = "${var.scopes}"
  }

  tags = [
    "remote-mgmt",
  ]

  depends_on = ["google_project_services.bootstrap_project_apis"]
}

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

resource "random_id" "project" {
  byte_length = 4
}

resource "google_project" "shared_networking" {
  name                = "${var.shared_networking_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_networking_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
}

resource "google_project" "shared_security" {
  name                = "${var.shared_security_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_security_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
}

resource "google_project" "shared_itsm" {
  name                = "${var.shared_itsm_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_itsm_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
}

resource "google_project" "shared_telemetry" {
  name                = "${var.shared_telemetry_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_telemetry_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
}

resource "google_project" "shared_billing" {
  name                = "${var.shared_billing_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_billing_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
}

resource "google_project" "shared_ssp" {
  name                = "${var.shared_ssp_project_name}-${random_id.project.hex}"
  project_id          = "${var.shared_ssp_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
}

resource "google_project" "tb_bastion" {
  name                = "${var.tb_bastion_project_name}-${random_id.project.hex}"
  project_id          = "${var.tb_bastion_project_name}-${random_id.project.hex}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
}

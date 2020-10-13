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


resource "google_project" "shared_networking" {
  name                = "${var.shared_networking_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_networking_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  labels              = var.labels
}

resource "google_project_iam_member" "shared_networking_custom_iam_bindings" {
  count   = length(var.shared_networking_project_custom_iam_bindings)
  project = google_project.shared_networking.project_id
  member  = var.shared_networking_project_custom_iam_bindings[count.index].member
  role    = var.shared_networking_project_custom_iam_bindings[count.index].role
}

resource "google_project" "shared_itsm" {
  name                = "${var.shared_itsm_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_itsm_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
  labels              = var.labels
}

resource "google_project" "shared_telemetry" {
  name                = "${var.shared_telemetry_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_telemetry_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
  labels              = var.labels
}

resource "google_project" "shared_billing" {
  name                = "${var.shared_billing_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_billing_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  labels              = var.labels
}

resource "google_project_iam_member" "shared_billing_custom_iam_bindings" {
  count   = length(var.shared_billing_project_custom_iam_bindings)
  project = google_project.shared_billing.project_id
  member  = var.shared_billing_project_custom_iam_bindings[count.index].member
  role    = var.shared_billing_project_custom_iam_bindings[count.index].role
}

resource "google_project" "shared_ec" {
  name                = "${var.shared_ec_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_ec_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
  labels              = var.labels
}

resource "google_project" "shared_bastion" {
  name                = "${var.shared_bastion_project_name}-${var.tb_discriminator}"
  project_id          = "${var.shared_bastion_project_name}-${var.tb_discriminator}"
  folder_id           = var.root_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  depends_on          = [google_project.shared_networking]
  labels              = var.labels
}
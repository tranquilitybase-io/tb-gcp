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
  region = var.region
  zone = var.zone
  version = "~> 2.5"
}


## RESOURCES
resource "google_service_account" "test_sa" {
  account_id   = "test-sa"
  display_name = "test-sa"
  project = var.project_id
}


resource "google_compute_instance" "test_instance" {
  project = var.project_id
  name = var.machine_name
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"

    access_config {
      // REQUIRED TO ALLOW SSH
    }
  }

  //metadata_startup_script = "echo tf_metadata_startup_script executed in folder: $(pwd) Terraform version: $(terraform --version) > /tf_test.txt"

  service_account {
    email = google_service_account.test_sa.email
    scopes = [
      "cloud-platform"]
  }
}


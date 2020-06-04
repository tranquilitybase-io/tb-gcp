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

data "google_project" "shared-vpc" {
  project_id = var.sharedvpc_project_id
}

data "google_compute_network" "shared-vpc" {
  provider = google.shared-vpc
  name     = var.sharedvpc_network
  project  = var.sharedvpc_project_id
}

data "google_compute_subnetwork" "bastion" {
  provider = google.shared-vpc
  name     = var.bastion_subnetwork
  project  = var.sharedvpc_project_id
  region   = var.region
}

data "google_client_config" "default" {
}

data "google_compute_zones" "available" {
  region = var.region
}

data "google_compute_image" "debian9" {
  family  = "debian-9"
  project = "debian-cloud"
}


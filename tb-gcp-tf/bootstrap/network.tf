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

#CREATE-CUSTOM-VPC
resource "google_compute_network" "bootstrap_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
  project                 = google_project.bootstrap-res.project_id
  depends_on              = [google_project_services.bootstrap_project_apis]
}

resource "google_compute_subnetwork" "bootstrap_subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr_range
  region                   = var.region
  project                  = google_project.bootstrap-res.project_id
  network                  = google_compute_network.bootstrap_network.name
  private_ip_google_access = true
}

#CREATE-CLOUD-NAT-ROUTER
resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.bootstrap_network.name
  project = google_project.bootstrap-res.project_id
  region  = var.region
}

resource "google_compute_address" "nat_gw_ip" {
  address_type = "EXTERNAL"
  name         = "${var.router_nat_name}-ip"
  region       = var.region
  project      = google_project.bootstrap-res.project_id
  depends_on   = [google_project_services.bootstrap_project_apis]
}

resource "google_compute_router_nat" "nat_gw" {
  name                               = var.router_nat_name
  project                            = google_project.bootstrap-res.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_gw_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

#CREATE-IAP-FIREWALL-RULES
resource "google_compute_firewall" "fw_iap_ingress_ssh" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  description   = "Allows known IAP IP ranges to SSH into VMs"
  name          = "allow-iap-ingress-ssh"
  network       = google_compute_network.bootstrap_network.name
  project       = google_project.bootstrap-res.project_id
  source_ranges = ["35.235.240.0/20"]
}


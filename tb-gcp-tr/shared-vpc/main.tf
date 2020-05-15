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

###
# Shared VPC setup
###

resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

###
# Network and Subnetworks
###
resource "google_compute_network" "shared_network" {
  name                    = var.shared_vpc_name
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
  project                 = var.host_project_id
  depends_on              = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_subnetwork" "standard" {
  count         = length(var.standard_network_subnets)
  name          = var.standard_network_subnets[count.index]["name"]
  ip_cidr_range = var.standard_network_subnets[count.index]["cidr"]
  region        = var.region
  project       = var.host_project_id
  network       = google_compute_network.shared_network.name

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling         = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  #labels           = "${var.tags}"
  depends_on = [google_compute_network.shared_network]
}

resource "google_compute_subnetwork" "gke" {
  count                    = length(var.gke_network_subnets)
  name                     = var.gke_network_subnets[count.index]["name"]
  ip_cidr_range            = var.gke_network_subnets[count.index]["cidr"]
  region                   = var.region
  private_ip_google_access = true
  project                  = var.host_project_id
  network                  = google_compute_network.shared_network.name

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling         = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  #labels           = "${var.tags}"
  depends_on = [google_compute_network.shared_network]

  # Kubernetes Secondary Networking
  secondary_ip_range {
    range_name    = var.gke_pod_network_name
    ip_cidr_range = var.gke_network_subnets[count.index]["pod_cidr"]
  }

  secondary_ip_range {
    range_name    = var.gke_service_network_name
    ip_cidr_range = var.gke_network_subnets[count.index]["service_cidr"]
  }
}

resource "google_compute_subnetwork" "shared-bastion-subnetwork" {
  name                     = "bastion-subnetwork"
  ip_cidr_range            = "10.0.6.0/24"
  region                   = var.region
  private_ip_google_access = true
  project                  = var.host_project_id
  network                  = google_compute_network.shared_network.name

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling         = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [
  google_compute_network.shared_network]
}
###
# Additional Networking Resources
###
resource "google_compute_address" "static" {
  name    = "nat-static-ip"
  project = var.host_project_id
}

resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.shared_network.self_link
  project = var.host_project_id
  region  = var.region
}

resource "google_compute_router_nat" "simple-nat" {
  count                              = var.create_nat_gateway ? 1 : 0
  name                               = var.router_nat_name
  project                            = var.host_project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.static.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}



###
# Attaching service projects
###

resource "google_compute_shared_vpc_service_project" "service_project" {
  count           = var.service_projects_number
  host_project    = var.host_project_id
  service_project = var.service_project_ids[count.index]

  #labels          = "${var.tags}"
  depends_on = [
    google_compute_shared_vpc_host_project.host,
    google_compute_subnetwork.gke,
    google_compute_subnetwork.standard,
  ]
}

###
# Creating a private DNS
###

resource "google_dns_managed_zone" "private-zone" {
  name        = var.private_dns_name
  dns_name    = var.private_dns_domain_name
  project     = var.host_project_id
  description = "Private DNS zone"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.shared_network.self_link
    }
  }
  depends_on = [
    google_compute_shared_vpc_host_project.host
  ]
}
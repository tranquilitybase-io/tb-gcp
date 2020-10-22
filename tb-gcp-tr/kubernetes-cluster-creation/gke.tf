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

resource "google_container_cluster" "gke" {
  project  = var.cluster_project_id
  name     = var.cluster_name
  location = var.region
  provider = google-beta

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool    = true
  enable_shielded_nodes       = var.enable_shielded_nodes
  enable_intranode_visibility = var.enable_intranode_visibility

  initial_node_count = 1

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.cluster_daily_maintenance_start
    }
  }
  monitoring_service = var.pod-mon-service
  logging_service    = var.pod-log-service
  enable_legacy_abac = false
  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # use latest version, unless a specific version requested
  min_master_version = var.cluster_min_master_version

  # setting the default maximum number of pods per node in this cluster.
  default_max_pods_per_node = var.cluster_default_max_pods_per_node

  # specifying node_config here causes terraform to re-create the cluster on EVERY execution

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.cluster_master_authorized_cidrs
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
  network    = "projects/${var.sharedvpc_project_id}/global/networks/${var.sharedvpc_network}"
  subnetwork = "projects/${var.sharedvpc_project_id}/regions/${var.region}/subnetworks/${var.cluster_subnetwork}"

  # ensure secondary networks are created in the order pod network, then services network
  ip_allocation_policy {
    cluster_secondary_range_name  = var.gke_pod_network_name
    services_secondary_range_name = var.gke_service_network_name
  }
  private_cluster_config {
    enable_private_endpoint = var.cluster_enable_private_endpoint
    enable_private_nodes    = var.cluster_enable_private_nodes
    master_ipv4_cidr_block  = var.cluster_master_cidr
  }

  addons_config {
    istio_config {
      #      disabled = "false"
      disabled = var.istio_status
      auth     = var.istio_permissive_mtls == "true" ? "AUTH_NONE" : "AUTH_MUTUAL_TLS"
    }
  }

  # ensure service accounts are created before cluster creation
  depends_on = [
    google_service_account.cluster,
    null_resource.shared_vpc_created,
    google_project_iam_member.cluster_hostServiceAgentUser,
    google_compute_subnetwork_iam_member.cluster_networkUser_1,
    google_compute_subnetwork_iam_member.cluster_networkUser_2,
  ]
}

resource "google_container_node_pool" "gke_node_pool" {
  project  = var.cluster_project_id
  name     = var.cluster_pool_name
  location = var.region

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  node_count = 1
  cluster    = google_container_cluster.gke.name

  autoscaling {
    min_node_count = var.cluster_autoscaling_min_nodes
    max_node_count = var.cluster_autoscaling_max_nodes
  }

  node_config {
    disk_size_gb    = var.cluster_node_disk_size
    machine_type    = var.cluster_machine_type
    oauth_scopes    = var.cluster_oauth_scopes
    service_account = google_service_account.cluster.email
    tags            = ["gke-private", var.cluster_name]

    shielded_instance_config {
      enable_secure_boot = var.enable_secure_boot

      enable_integrity_monitoring = var.enable_integrity_monitoring
    }

    workload_metadata_config {
      // Enables Metadata Concealment which is the 2nd most secure option after GKE Metadata Server (commented option below)
      node_metadata = "SECURE"
    }

  }
  depends_on = [google_container_cluster.gke]
}


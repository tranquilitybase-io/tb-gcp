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

variable "region" {
  type        = string
  description = "The region to host the cluster in"
}

variable "sharedvpc_project_id" {
  type = string
}

variable "sharedvpc_network" {
  type = string
}

variable "cluster_project_id" {
  description = "The project ID to host the cluster in"
}

variable "cluster_name" {
  description = "The cluster name"
}

variable "cluster_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "cluster_enable_private_nodes" {
  default = "false"
  type    = string
}

variable "cluster_enable_private_endpoint" {
  default = false
  type    = bool
}

variable "cluster_master_cidr" {
  type = string
}

variable "cluster_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_service_account_roles" {
  type        = list(string)
  default     = []
  description = "Service account to associate to the nodes in the cluster"
}

variable "pod-mon-service" {
  type    = string
  default = "monitoring.googleapis.com/kubernetes"
}

variable "pod-log-service" {
  type    = string
  default = "logging.googleapis.com/kubernetes"
}

variable "cluster_min_master_version" {
  default     = "latest"
  description = "Master node minimal version"
  type        = string
}

variable "cluster_autoscaling_min_nodes" {
  type    = string
  default = "1"
}

variable "cluster_autoscaling_max_nodes" {
  type    = string
  default = "3"
}

variable "cluster_master_authorized_cidrs" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "cluster_daily_maintenance_start" {
  type    = string
  default = "02:00"
}

variable "cluster_node_disk_size" {
  type    = string
  default = "30"
}

variable "cluster_oauth_scopes" {
  type = list(string)
  default = [
    "compute-rw",
    "storage-ro",
    "logging-write",
    "monitoring",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

variable "apis_dependency" {
  type        = string
  description = "Creates dependency on apis-activation module"
}

variable "shared_vpc_dependency" {
  type        = string
  description = "Creates dependency on shared-vpc module"
}

variable "shared_ec_dependency" {
  type        = string
  description = "Creates dependency on shared_projects"
}

variable "istio_permissive_mtls" {
  type    = string
  default = "false"
}

variable "istio_status" {
  type    = string
  default = "true"
}

variable "gke_pod_network_name" {
  type        = string
  default     = "gke-pods-snet"
  description = "Name for the gke pod network"
}

variable "gke_service_network_name" {
  type        = string
  default     = "gke-services-snet"
  description = "Name for the gke service network"
}

variable "cluster_default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  default     = null
}

variable "enable_intranode_visibility" {
  description = "Enabled visibility of traffic between nodes."
  default     = true
}

variable "enable_secure_boot" {
  description = "Enabled secure boot for nodes."
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Enables integrity monitoring"
  default     = true
}
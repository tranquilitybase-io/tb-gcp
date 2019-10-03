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

#FOLDER STRUCTURE CREATION
variable "region" {
  type        = "string"
  default     = "europe-west2"
  description = "region name."
}

variable "region_zone" {
  type        = "string"
  default     = "europe-west2-a"
  description = "zone name in the region provided."
}

variable "root_id" {
  type        = "string"
  description = "id for the parent where these folders will be created."
}

variable "root_is_org" {
  type        = "string"
  default     = "false"
  description = "determines whether root directory is an org or a directory inside an org."
}

variable "tb_discriminator" {
  type = "string"
  default = ""
  description = "sufix added to the Tranquility Base folder allowing coexistence of other TBase instances within the same Organisation/Folder. Example: 'uat', 'dev-am'. Default value is empty so no suffix will be added."
}

#SHARED PROJECTS CREATION
variable "billing_account_id" {
  type        = "string"
  description = "Id of billing account thi which projects will be assigned"
}

variable "shared_networking_project_name" {
  type        = "string"
  default     = "shared-networking"
  description = "Shared networking project name."
}

variable "shared_security_project_name" {
  type        = "string"
  default     = "shared-security"
  description = "Shared security project name."
}

variable "shared_telemetry_project_name" {
  type        = "string"
  default     = "shared-telemetry"
  description = "Shared telemetry project name."
}

variable "shared_operations_project_name" {
  type        = "string"
  default     = "shared-operations"
  description = "Shared operations project name."
}

variable "shared_billing_project_name" {
  type        = "string"
  default     = "shared-billing"
  description = "Shared billing project name."
}

# SHARED VPC
variable shared_vpc_name {
  type        = "string"
  default     = "shared-network"
  description = "Name for the shared vpc network"
}

variable standard_network_subnets {
  type        = "list"
  default     = []
  description = "cidr ranges for standard (non-gke) subnetworks"
}

variable enable_flow_logs {
  type        = "string"
  default     = "false"
  description = "Boolean value to determine whether to enable flowlogs in subnet creation"
}

variable tags {
  type        = "map"
  default     = {}
  description = "A map of tags to add to all resources"
}

variable gke_network_subnets {
  type        = "list"
  default     = []
  description = "cidr ranges for gke subnetworks"
}

variable "gke_pod_network_name" {
  type        = "string"
  default     = "gke-pods-snet"
  description = "Name for the gke pod network"
}

variable "gke_service_network_name" {
  type        = "string"
  default     = "gke-services-snet"
  description = "Name for the gke service network"
}

variable router_name {
  type        = "string"
  default     = "vpc-network-router"
  description = "router name"
}

variable create_nat_gateway {
  type        = "string"
  default     = "true"
  description = "Boolean value to determine whether to create a NAT gateway"
}

variable router_nat_name {
  type        = "string"
  default     = "vpc-network-nat-gateway"
  description = "Name for the router NAT gateway"
}

variable "service_projects_number" {
  type        = "string"
  default     = ""
  description = "Number of service projects attached to shared vpc host"
}

#KUBERNETES CLUSTERS
variable "cluster_ssp_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_sec_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_sec_oauth_scope" {
  description = "API scope to be given to Security Cluster, for vault leave default value"
  default = ["cloud-platform"]
 }

variable "cluster_sec_service_account_roles" {
  type        = "list"
  default     = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_opt_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_ssp_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_sec_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_opt_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_ssp_name" {
  description = "The cluster name"
}

variable "cluster_sec_name" {
  description = "The cluster name"
}

variable "cluster_opt_name" {
  description = "The cluster name"
}

variable "cluster_ssp_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_sec_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_opt_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_opt_enable_private_nodes" {
  type = "string"
}

variable "cluster_sec_enable_private_nodes" {
  type = "string"
}

variable "cluster_ssp_enable_private_nodes" {
  type = "string"
}

variable "cluster_ssp_master_cidr" {
  type = "string"
}

variable "cluster_sec_master_cidr" {
  type = "string"
}

variable "cluster_opt_master_cidr" {
  type = "string"
}

variable "cluster_ssp_master_authorized_cidrs" {
  type = "list"
}

variable "cluster_sec_master_authorized_cidrs" {
  type = "list"
}

variable "cluster_opt_master_authorized_cidrs" {
  type = "list"
}

variable "cluster_opt_min_master_version" {
  default = "latest"
  description = "Master node minimal version"
  type = "string"
}

variable "cluster_sec_min_master_version" {
  default = "latest"
  description = "Master node minimal version"
  type = "string"
}

variable "cluster_ssp_min_master_version" {
  default = "latest"
  description = "Master node minimal version"
  type = "string"
}

variable "istio_status" {
  type    = "string"
  default = "true"

  #  description = "the default behaviour is to not installed"
}

# SSP Deployment
variable "application_yaml_path" {
  description = "Path to the yaml file describing the application resources"
  type        = "string"
}

variable "ssp_repository_name" {
  type        = "string"
  description = "Repository name used to store activator code"
}

variable "endpoint_file" {
  type        = "string"
  description = "Path to local file that will be created to store istio endpoint. The file will be created in the terraform run or overwritten (if exists). You need to ensure that directory in which it's created exists"
  default = "/opt/tb/repo/tb-gcp-tr/gae-self-service-portal/endpoint-meta.json"

}

variable "ssp_iam_service_account_roles" {
  type = "list"
  description = "Roles attached to service account"
}

# Vault deployment
variable "vault-lb-name" {
  type = "string"
}

variable "sec-vault-keyring" {
  type = "string"
 }

variable "location" {
  type = "string"
  default = "EU"
}

variable "sec-vault-crypto-key-name" {
  type = "string"
}

variable "sec-lb-name" {
  type = "string"
}

#iTop deployment
variable "itop_database_user_name" {
  description = "iTop's database user account name"
  default = "itop"
  type = "string"
}

#TLS Certs
variable "cert-common-name" {
  type = "string"
 }

variable "tls-organization" {
  type = "string"
}

variable "terraform_state_bucket_name" {
  type = "string"
}

variable "clusters_master_whitelist_ip" {
  description = "IP to add to the GKE clusters' master authorized networks"
  type = "string"
}

variable "ssp_ui_source_bucket" {
  description = "GCS Bucket hosting Self Service Portal Angular source code."
  type = "string"
}

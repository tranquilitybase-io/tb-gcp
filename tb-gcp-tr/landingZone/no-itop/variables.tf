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
  type        = string
  description = "region name."
}

variable "region_zone" {
  type        = string
  description = "zone name in the region provided."
}

variable "root_id" {
  type        = string
  description = "id for the parent where these folders will be created."
}

variable "tb_discriminator" {
  type        = string
  default     = ""
  description = "sufix added to the Tranquility Base folder allowing coexistence of other TBase instances within the same Organisation/Folder. Example: 'uat', 'dev-am'. Default value is empty so no suffix will be added."
}

#SHARED PROJECTS CREATION
variable "billing_account_id" {
  type        = string
  description = "Id of billing account thi which projects will be assigned"
}

variable "shared_networking_project_name" {
  type        = string
  default     = "shared-networking"
  description = "Shared networking project name."
}

variable "shared_telemetry_project_name" {
  type        = string
  default     = "shared-telemetry"
  description = "Shared telemetry project name."
}

variable "shared_itsm_project_name" {
  type        = string
  default     = "shared-itsm"
  description = "Shared itsm project name."
}

variable "shared_billing_project_name" {
  type        = string
  default     = "shared-billing"
  description = "Shared billing project name."
}

variable "shared_bastion_project_name" {
  type        = string
  default     = "shared-bastion"
  description = "Name for bastion project"
}

# SHARED VPC
variable "shared_vpc_name" {
  type        = string
  default     = "shared-network"
  description = "Name for the shared vpc network"
}

variable "standard_network_subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "shared-network-snet",
      cidr = "10.0.0.0/24"
  }]

  description = "cidr ranges for standard (non-gke) subnetworks"
}

variable "enable_flow_logs" {
  type        = string
  default     = "false"
  description = "Boolean value to determine whether to enable flowlogs in subnet creation"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

variable "gke_network_subnets" {
  type = list(object({
    name         = string
    cidr         = string
    pod_cidr     = string
    service_cidr = string
  }))
  description = "cidr ranges for gke subnetworks"
  default = [
    {
      name         = "shared-ec-snet",
      cidr         = "10.0.1.0/24",
      pod_cidr     = "10.1.0.0/17",
      service_cidr = "10.1.128.0/20"
    },
    {
      name         = "shared-itsm-snet",
      cidr         = "10.0.2.0/24",
      pod_cidr     = "10.2.0.0/17",
      service_cidr = "10.2.128.0/20"
    },
    {
      name         = "activator-project-snet",
      cidr         = "10.0.4.0/24",
      pod_cidr     = "10.4.0.0/17",
      service_cidr = "10.4.128.0/20"
    },
    {
      name         = "workspace-project-snet",
      cidr         = "10.0.5.0/24",
      pod_cidr     = "10.5.0.0/17",
      service_cidr = "10.5.128.0/20"
  }]
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

variable "bastion_subnetwork_cidr" {
  type        = string
  default     = "10.0.6.0/24"
  description = "ip range for bastion subnet"
}

variable "router_name" {
  type        = string
  default     = "vpc-network-router"
  description = "router name"
}

variable "create_nat_gateway" {
  type        = string
  default     = "true"
  description = "Boolean value to determine whether to create a NAT gateway"
}

variable "router_nat_name" {
  type        = string
  default     = "vpc-network-nat-gateway"
  description = "Name for the router NAT gateway"
}

variable "service_projects_number" {
  type        = string
  default     = ""
  description = "Number of service projects attached to shared vpc host"
}

#KUBERNETES CLUSTERS
variable "cluster_ec_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_opt_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_ec_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_opt_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_ec_name" {
  description = "The cluster name"
}

variable "cluster_opt_name" {
  description = "The cluster name"
}

variable "cluster_ec_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_opt_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_opt_enable_private_nodes" {
  type = string
}

variable "cluster_ec_enable_private_nodes" {
  type = string
}

#Bool input for whether opt cluster has private endpoint or not.
variable "cluster_opt_enable_private_endpoint" {
  type = bool
}

#Bool input for whether ec cluster has private endpoint or not.
variable "cluster_ec_enable_private_endpoint" {
  type = bool
}

variable "cluster_ec_master_cidr" {
  type    = string
  default = "172.16.0.0/28"
}

variable "cluster_ec_master_authorized_cidrs" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "10.0.0.0/8",
      display_name = "mgmt-1"
    },
    {
      cidr_block   = "10.0.6.0/24",
      display_name = "proxy-subnet"
    }
  ]
}

variable "cluster_opt_master_cidr" {
  type    = string
  default = "172.16.0.32/28"
}

variable "cluster_opt_master_authorized_cidrs" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "10.0.0.0/8",
      display_name = "mgmt-1"
    },
    {
      cidr_block   = "10.0.6.0/24",
      display_name = "proxy-subnet"
    }
  ]
}

variable "cluster_opt_min_master_version" {
  default     = "latest"
  description = "Master node minimal version"
  type        = string
}

variable "cluster_ec_min_master_version" {
  default     = "latest"
  description = "Master node minimal version"
  type        = string
}

variable "cluster_ec_default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  default     = null
}

variable "istio_status" {
  type    = string
  default = "true"
  #  description = "the default behaviour is to not installed"
}

# EC Deployment
variable "eagle_console_yaml_path" {
  description = "Path to the yaml file describing the eagle console resources"
  type        = string
}

variable "ec_repository_name" {
  type        = string
  description = "Repository name used to store activator code"
}

variable "endpoint_file" {
  type        = string
  description = "Path to local file that will be created to store istio endpoint. The file will be created in the terraform run or overwritten (if exists). You need to ensure that directory in which it's created exists"
  default     = "/opt/tb/repo/tb-gcp-tr/gae-self-service-portal/endpoint-meta.json"
}

variable "ec_iam_service_account_roles" {
  type        = list(string)
  description = "Roles attached to service account"
}

#iTop deployment
variable "itop_database_user_name" {
  description = "iTop's database user account name"
  default     = "itop"
  type        = string
}

variable "terraform_state_bucket_name" {
  type = string
}

variable "clusters_master_whitelist_ip" {
  description = "IP to add to the GKE clusters' master authorized networks"
  type        = string
}

variable "ec_ui_source_bucket" {
  description = "GCS Bucket hosting Self Service Portal Angular source code."
  type        = string
}

variable "private_dns_name" {
  type        = string
  default     = ""
  description = "Name for private DNS zone in the shared vpc network"
}

variable "private_dns_domain_name" {
  type        = string
  default     = ""
  description = "Domain name for private DNS in the shared vpc network"
}
## DAC Services ##########
# Namespace creations
variable "sharedservice_namespace_yaml_path" {
  description = "Path to the yaml file to create namespaces on the shared gke-ec cluster"
  type        = string
}

# Jenkins install 
variable "sharedservice_jenkinsmaster_yaml_path" {
  description = "Path to the yaml file to deploy Jenkins on the shared gke-ec cluster"
  type        = string
}

### Bucket KMS Key ###
variable "kms_key_ring_project_id" {
  type = string
}
variable "kms_key_ring_name" {
  type = string
  default = "tf-state-bucket-keyring"
}
variable "kms_key_ring_location" {
  type = string
  default = "europe"
}
variable "kms_key_name" {
  type = string
  default = "tf-state-bucket-key"
}
variable "kms_key_rotation_period" {
  type = string
  default = "2592000s" #1 month
}
variable "kms_key_purpose" {
  type = string
  default = "ENCRYPT_DECRYPT" #symmetric key
}
variable "kms_key_algorithm" {
  type = string
  default = "GOOGLE_SYMMETRIC_ENCRYPTION" #uses AES256
}
variable "kms_key_protection_level" {
  type = string
}
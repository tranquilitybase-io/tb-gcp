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

variable "shared_networking_project_custom_iam_bindings" {
  default     = []
  description = "List of custom IAM bindings that should be added to the shared networking project's policy. An item consists in a map containing a cloud identity member (such as group:name@example.com) and a IAM role (such as roles/compute.viewer)"
  type = list(object({
    member = string
    role   = string
  }))
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

variable "shared_billing_project_custom_iam_bindings" {
  default     = []
  description = "List of custom IAM bindings that should be added to the shared billing project's policy. An IAM binding consists of a map containing a cloud identity `member` (such as group:name@example.com) and a IAM `role` (such as roles/bigquery.admin)"
  type = list(object({
    member = string
    role   = string
  }))
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

variable "bastion_subnetwork_name" {
  default     = "shared-bastion"
  description = "bastion subnetwork name"
  type        = string
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
  default     = 2
  description = "Number of service projects attached to shared vpc host"
  type        = number
}

#KUBERNETES CLUSTERS
variable "cluster_ec_service_account" {
  default     = "kubernetes-ec"
  description = "Service account to associate to the nodes in the cluster"
  type        = string
}

variable "cluster_opt_service_account" {
  default     = "kubernetes-opt"
  description = "Service account to associate to the nodes in the cluster"
  type        = string
}

variable "cluster_ec_subnetwork" {
  default     = "shared-ec-snet"
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "cluster_opt_subnetwork" {
  default     = "shared-itsm-snet"
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "cluster_ec_name" {
  default     = "gke-ec"
  description = "The cluster name"
  type        = string
}

variable "cluster_opt_name" {
  default     = "gke-opt"
  description = "The cluster name"
  type        = string
}

variable "cluster_ec_pool_name" {
  default     = "gke-ec-node-pool"
  description = "The cluster pool name"
  type        = string
}

variable "cluster_opt_pool_name" {
  default     = "gke-opt-node-pool"
  description = "The cluster pool name"
  type        = string
}

variable "cluster_opt_enable_private_nodes" {
  default     = true
  description = "When set to true the ITSM Kubernetes worker nodes will not be assigned public IPs."
  type        = bool
}

variable "cluster_ec_enable_private_nodes" {
  default     = true
  description = "When set to true the EC Kubernetes worker nodes will not be assigned public IPs."
  type        = bool
}

#Bool input for whether opt cluster has private endpoint or not.
variable "cluster_opt_enable_private_endpoint" {
  default     = false
  description = "When set to true the ITSM Kubernetes master endpoint will not have a public IP endpoint."
  type        = bool
}

#Bool input for whether ec cluster has private endpoint or not.
variable "cluster_ec_enable_private_endpoint" {
  default     = true
  description = "When set to true the EC Kubernetes master endpoint will not have a public IP endpoint."
  type        = bool
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
  type        = bool
  default     = true
  description = "When true, GKE's Istio is not installed."
}

# EC Deployment
variable "eagle_console_yaml_path" {
  default     = "/opt/tb/repo/tb-gcp-tr/shared-dac/eagle_console.yaml"
  description = "Path to the yaml file describing the eagle console resources"
  type        = string
}

variable "ec_repository_name" {
  default     = "EC-activator-tf"
  description = "Repository name used to store activator code"
  type        = string
}

variable "endpoint_file" {
  type        = string
  description = "Path to local file that will be created to store istio endpoint. The file will be created in the terraform run or overwritten (if exists). You need to ensure that directory in which it's created exists"
  default     = "/opt/tb/repo/tb-gcp-tr/gae-self-service-portal/endpoint-meta.json"
}

variable "ec_iam_service_account_roles" {
  default = [
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/compute.xpnAdmin",
    "roles/resourcemanager.projectDeleter",
    "roles/billing.projectManager",
    "roles/owner",
    "roles/compute.networkAdmin",
    "roles/datastore.owner",
    "roles/browser",
    "roles/resourcemanager.projectIamAdmin"
  ]
  description = "Roles attached to service account"
  type        = list(string)
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
  default     = "tranquility-base-ui"
  description = "GCS Bucket hosting Self Service Portal Angular source code."
  type        = string
}

variable "private_dns_name" {
  type        = string
  default     = "private-shared"
  description = "Name for private DNS zone in the shared vpc network"
}

variable "private_dns_domain_name" {
  type        = string
  default     = "tranquilitybase-demo.io." # domain requires . to finish
  description = "Domain name for private DNS in the shared vpc network"
}
## DAC Services ##########
# Namespace creations
variable "sharedservice_namespace_yaml_path" {
  default     = "/opt/tb/repo/tb-gcp-tr/shared-dac/namespaces.yaml"
  description = "Path to the yaml file to create namespaces on the shared gke-ec cluster"
  type        = string
}

# StorageClasses creation
variable "sharedservice_storageclass_yaml_path" {
  default     = "/opt/tb/repo/tb-gcp-tr/shared-dac/storageclasses.yaml"
  description = "Path to the yaml file to create storageclasses on the shared gke-ec cluster"
  type        = string
}

# Jenkins install 
variable "sharedservice_jenkinsmaster_yaml_path" {
  default     = "/opt/tb/repo/tb-gcp-tr/shared-dac/jenkins-master.yaml"
  description = "Path to the yaml file to deploy Jenkins on the shared gke-ec cluster"
  type        = string
}

variable "labels" {
  type        = map(string)
  description = "Labels to assign to resources."
}

#GCS bucket logging
variable "gcs_logs_bucket_prefix" {
  description = "Prefix of the access logs & storage logs storage bucket"
  type        = string
  default     = "tb-bucket-access-storage-logs"
}

variable "iam_members_bindings" {
  description = "The list of IAM members to grant permissions for the logs bucket"
  type = list(object({
    role   = string,
    member = string
  }))
  default = [{
    role   = "roles/storage.legacyBucketWriter",
    member = "group:cloud-storage-analytics@google.com"
  }]
}

##### Audit logging #####

### Audit Bucket ###

variable "tb_folder_admin_rw_audit_log_bucket_filter" {
  default     = "logName:(/logs/cloudaudit.googleapis.com%2Factivity OR /logs/cloudaudit.googleapis.com%2Fsystem_event)"
  description = "TB folder admin read/write bucket audit logs filter"
  type        = string
}

variable "tb_folder_admin_rw_audit_log_bucket_location" {
  description = "location for tb folder admin read/write bucket audit logs"
  type        = string
  default     = "europe-west2"
}
variable "tb_folder_admin_rw_audit_log_bucket_storage_class" {
  description = "storage class for tb folder admin read/write bucket audit logs"
  type        = string
  default     = "REGIONAL"
}
variable "tb_folder_admin_rw_audit_log_bucket_name" {
  description = "bucket name for tb folder admin read/write bucket audit logs"
  type        = string
  default     = "tb-folder-admin-rw-audit-logs"
}
variable "tb_folder_admin_rw_audit_log_bucket_labels" {
  description = "labels for tb folder admin read/write bucket audit logs"
  type        = map(string)
  default     = { "function" = "bucket-to-store-root-folder-admin-rw-audit-logs" }
}
variable "tb_folder_admin_rw_audit_log_bucket_lifecycle_rules" {
  description = "lifecycle rules for tb folder admin read/write bucket audit logs. Defaults to moving from standard to nearline after 30 days and deleting after 365."
  default = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      },
      condition = {
        age = "30"
      }
    },
    {
      action = {
        type          = "Delete"
        storage_class = ""
      },
      condition = {
        age = "365"
      }
    }
  ]
}

### Audit Folder Log Sink Creator ###

variable "tb_folder_admin_rw_audit_log_sink_name" {
  description = "log sink name for tb folder admin read/write bucket audit logs"
  default     = "tb-folder-admin-rw-audit-log-sink"
  type        = string
}
variable "include_children" {
  description = "include logs for folders and project below the tb folder"
  default     = true
  type        = bool
}

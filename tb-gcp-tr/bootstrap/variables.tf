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

#PROVIDER
variable "region" {
  type        = string
  description = "Region name."
}

variable "region_zone" {
  type        = string
  description = "Zone name in the region provided."
}

variable "folder_id" {
  type        = string
  description = "Id for the parent folder where this project will be created."
}

variable "billing_account_id" {
  type        = string
  description = "Id of billing account to which bootstrap project will be assigned"
}

variable "tb_discriminator" {
  type        = string
  description = "sufix added to the names/IDs such elements like Tranquility Base folder, Bootstrap project what allows their coexistence with other sibling TBase instances within the same Organisation/Folder. Example: 'uat', 'dev-am', ''. For the empty value no suffix will be added (thus production ready)."
}

#CREATE-CUSTOM-VPC
variable "vpc_name" {
  default = "bootstrap"
  type    = string
}

variable "subnet_name" {
  default = "bootstrap"
  type    = string
}

variable "subnet_cidr_range" {
  default = "192.168.0.0/28"
  type    = string
}

#CREATE-CLOUD-NAT-ROUTER
variable "router_name" {
  type        = string
  default     = "vpc-network-router"
  description = "Cloud NAT router name"
}

variable "router_nat_name" {
  type        = string
  default     = "vpc-network-nat-gateway"
  description = "Cloud NAT gateway name"
}

#CREATE-BOOTSTRAP-TERRAFORM-SERVER
variable "terraform_server_name" {
  type    = string
  default = "terraform-server"
}

variable "terraform_server_machine_type" {
  type    = string
  default = "g1-small"
}

variable "bootstrap_host_disk_image" {
  type        = string
  default     = "family/tb-tr-debian-9"
  description = "reference to a GCR VM image which will be used for terraform-server instance creation. For more details regarding accepted image references see: https://www.terraform.io/docs/providers/google/r/compute_instance.html#image"
}

variable "metadata_startup_script" {
  type        = string
  default     = "files/bootstrap.sh"
  description = "Local path to a bootstrap startup script template. Default value is 'files/bootstrap.sh'."
}

variable "enable_itop" {
  type = string
  description = "Set it to false in order to disable iTop"
}

variable "scopes" {
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
  description = "A list of service scopes attached to the bootstrap terraform server. To allow full access to all Cloud APIs, use the cloud-platform scope. For other scopes see here: https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes "
}

variable "main_iam_service_account_roles" {
  type = list(string)
  default = [
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter",
    "roles/billing.projectManager",
    "roles/compute.xpnAdmin",
    "roles/owner",
    "roles/compute.networkAdmin",
  ]
  description = "Roles attached to service account"
}


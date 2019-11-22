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
    type = "string"
    default = "europe-west2"
    description = "Region name."
}

variable "region_zone" {
    type = "string"
    default = "europe-west2-a"
    description = "Zone name in the region provided."
}

variable "folder_id" {
    type = "string"
    description = "Id for the parent folder where this project will be created."
}

variable "billing_account_id" {
    type = "string"
    description = "Id of billing account to which bootstrap project will be assigned"
}

variable "tb_discriminator" {
  type = "string"
  description = "sufix added to the names/IDs such elements like Tranquility Base folder, Bootstrap project what allows their coexistence with other sibling TBase instances within the same Organisation/Folder. Example: 'uat', 'dev-am', ''. For the empty value no suffix will be added (thus production ready)."
}

variable "lz_branch" {
  type = "string"
  description = "branch name used during github cloning of Landing Zone repo (eg. tb-gcp-tr) for building Landing Zone infrastructure via Bootstrap terraform host."
}

#CREATE-CUSTOM-VPC
variable "vpc_name" {
  default = "bootstrap"
  type = "string"
}

variable "subnet_name" {
  default = "bootstrap"
  type = "string"
}

variable "subnet_cidr_range" {
  default = "192.168.0.0/28"
  type = "string"
}

#CREATE-CLOUD-NAT-ROUTER
variable "router_name" {
  type = "string"
  default = "vpc-network-router"
  description = "Cloud NAT router name"
}

variable "router_nat_name" {
  type = "string"
  default = "vpc-network-nat-gateway"
  description = "Cloud NAT gateway name"
}

#CREATE-BOOTSTRAP-TERRAFORM-SERVER
variable "terraform_server_name" {
  type = "string"
}

variable "terraform_server_machine_type" {
  type = "string"
}

variable "bootstrap_host_disk_image" {
  type = "string"
}

variable "metadata_startup_script" {
  type = "string"
}

variable "scopes" {
  type = "list"
}

variable "main_iam_service_account_roles" {
  type = "list"
  description = "Roles attached to service account"
}

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

variable "credentials_file" {
  type = "string"
}

variable "region" {
  description = "The region to host the cluster in"
}

variable "sharedvpc_project_id" {
  type = "string"
}

variable "sharedvpc_network" {
  type = "string"
}

variable "bastion_service_account" {
  type        = "string"
  description = "Service account to associate to the bastion host"
}

variable "bastion_project_id" {
  description = "The project ID to host the cluster in"
}

variable "bastion_machine_type" {
  type = "string"
}

variable "bastion_name" {
  type = "string"
}

variable "bastion_subnetwork" {
  type = "string"
}

variable "bastion_source_cidr" {
  type = "list"
}

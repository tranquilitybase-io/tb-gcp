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
  description = "Zone for GCE resources"
  default = "europe-west2"
}

variable "zone" {
  description = "Zone for activator resources"
  default = "europe-west2-a"
}

variable "shared_network_name" {
  description = "Name of the Shared VPC"
}

variable "shared_networking_id" {
  type = "string"
  description = "Id of the project where Shared VPC was created"
}

variable "free_subnet_cidrs" {
  type = "list"
  description = "CIDR blocks for which subnets will be created"
}

variable "default_netmask" {
  type = "string"
  default = "8"
  description = "Default netmask used in secondary ip ranges to calculate CIDR's"
}

variable "subnets-name" {
  type = "list"
  description = "Name of subnets that will be created by script"
}
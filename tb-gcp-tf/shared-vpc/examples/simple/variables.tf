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
  default     = "europe-west2"
  type        = string
  description = "region name"
}

variable "region_zone" {
  default     = "europe-west2-a"
  type        = string
  description = "zone name in the region provided."
}

variable "host_project_id" {
  type        = string
  default     = "shared-vpc"
  description = "Identifier for the host project to be created"
}

variable "service_project_ids" {
  type        = list(string)
  default     = []
  description = "Associated service projects to link with the host project."
}

variable "standard_network_subnets" {
  type        = map(string)
  default     = {}
  description = "cidr ranges for standard (non-gke) subnetworks"
}

variable "gke_pod_network_name" {
  type        = string
  default     = "vpc-gke-pod-network"
  description = "Name for the gke pod network"
}

variable "gke_service_network_name" {
  type        = string
  default     = "vpc-gke-service-network"
  description = "Name for the gke service network"
}

variable "gke_node_network_subnets" {
  type        = map(string)
  default     = {}
  description = "cidr ranges for gke subnetworks"
}

variable "gke_pod_network_subnets" {
  type        = map(string)
  default     = {}
  description = "cidr ranges for pod subnets inside gke subnetworks"
}

variable "gke_service_network_subnets" {
  type        = map(string)
  default     = {}
  description = "cidr ranges for service subnets inside gke subnetworks"
}

variable "create_nat_gateway" {
  type        = string
  default     = true
  description = "Boolean value to determine whether to create a NAT gateway"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}


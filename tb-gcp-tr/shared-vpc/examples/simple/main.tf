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

# Setup of shared VPC on a provided, existing project, connects services accounts and basic subnets.
module "shared-vpc" {
  source = "../../"

  region      = var.region
  region_zone = var.region_zone

  host_project_id = var.host_project_id

  service_project_ids      = var.service_project_ids
  standard_network_subnets = var.standard_network_subnets

  gke_pod_network_name = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name

  gke_node_network_subnets = var.gke_node_network_subnets
  gke_pod_network_subnets = var.gke_pod_network_subnets
  gke_service_network_subnets = var.gke_service_network_subnets

  create_nat_gateway = var.create_nat_gateway

  tags = var.tags
  private_dns_name = var.private_dns_name
  private_dns_domain_name = var.private_dns_domain_name
}


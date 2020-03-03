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

# output "gke-security-endpoint" {
#    value = "${module.gke-security.endpoint}"
# }

# output "gke-security-ca" {
#    value = "${module.gke-security.master_auth.0.client_certificate}"
# }

output "sec-cluster_master_auth_0_client_key" {
  value = module.gke-security.cluster_master_auth_0_client_certificate
}

output "sec-gke-endpoint" {
  value = module.gke-security.cluster_endpoint
}

# iTop deployment
output "itop_db_user_password" {
  value = module.itop.database_instance_connection_password
}

output "vault-root-token" {
  value = module.vault.root_token
}

output "nat-static-ip" {
  value = module.shared-vpc.nat_static_ip
}

# The following outputs will be used to deploy the optional resources

output "shared_networking_id" {
  value = module.shared_projects.shared_networking_id
}

output "shared_operations_id" {
  value = module.shared_projects.shared_operations_id
}

output "all_apis_enabled" {
  value = module.apis_activation.all_apis_enabled
}

output "gke_subnetwork_ids" {
  value = module.shared-vpc.gke_subnetwork_ids
}

output "access_token" {
  value = data.google_client_config.current.access_token
}

output "region" {
  value = var.region
}

output "region_zone" {
  value = var.region_zone
}


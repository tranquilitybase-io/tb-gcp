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


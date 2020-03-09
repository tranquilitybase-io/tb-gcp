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

# output "gke-secrets-endpoint" {
#    value = "${module.gke-secrets.endpoint}"
# }

# output "gke-secrets-ca" {
#    value = "${module.gke-secrets.master_auth.0.client_certificate}"
# }

output "sec-cluster_master_auth_0_client_key" {
  value = module.gke-secrets.cluster_master_auth_0_client_certificate
}

output "sec-gke-endpoint" {
  value = module.gke-secrets.cluster_endpoint
}

output "vault-root-token" {
  value = module.vault.root_token
}

output "nat-static-ip" {
  value = module.shared-vpc.nat_static_ip
}


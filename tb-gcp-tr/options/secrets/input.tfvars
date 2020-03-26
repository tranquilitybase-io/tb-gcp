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
cluster_sec_subnetwork           = "shared-secrets-snet"
cluster_sec_service_account      = "kubernetes-sec"
cluster_sec_name                 = "gke-sec"
cluster_sec_pool_name            = "gke-sec-node-pool"
cluster_sec_enable_private_nodes = "true"
cluster_sec_master_cidr          = "172.16.0.16/28"
cluster_sec_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]

istio_status        = "false"
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"

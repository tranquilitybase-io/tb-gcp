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

output "k8s-context_id" {
  description = "identifier for the module output"
  value       = null_resource.k8s_config.id
}

output "context_name" {
  description = "GKE context name stored into ~/.kube/config"
  value       = "gke_${var.cluster_project}_${var.region}_${var.cluster_name}"
}


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

variable "cluster_config_path" {
  description = "Configuration file for kubernetes cluster"
  default     = "$HOME/.kube/config"
}

variable "cluster_context" {
  description = "GKE context name"
  default     = ""
  type        = string
}

variable "k8s_template_file" {
  description = "YAML file containing kubernetes deployment"
  type        = string
}

variable "dependency_var" {
  description = "Variable used only for dependency tracking"
  default     = "empty"
  type        = string
}


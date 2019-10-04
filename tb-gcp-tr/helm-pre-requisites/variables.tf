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

# Optional variables
variable "tiller_svc_accnt_name" {
  type        = string
  default     = "tiller"
  description = "K8 service account with cluster admin for Tiller to be able to deploy the Helm Charts"
}

variable "provider_alias" {
  type        = string
  default     = "common"
  description = "Provider's alias to differentiate configuration between GKE clusters"
}

//variable "tiller_image" {
//    type = "string"
//    default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
//    description = "The tiller image to deploy to the K8 cluster"
//}

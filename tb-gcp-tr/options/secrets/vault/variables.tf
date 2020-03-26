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
variable "terraform_state_bucket_name" {
  type = string
  description = "Name of the terraform state bucket"
}

variable "location" {
  type    = string
  default = "EU"
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "region name."
}

variable "sec-vault-keyring" {
  type = string
}

variable "sec-vault-crypto-key-name" {
  type = string
}

variable "sec-lb-name" {
  type = string
}

variable "cluster_sec_name" {
  description = "The cluster name"
}

variable "cert-common-name" {
  type = string
}

variable "tls-organization" {
  type = string
}

variable "vault-lb-name" {
  type = string
}

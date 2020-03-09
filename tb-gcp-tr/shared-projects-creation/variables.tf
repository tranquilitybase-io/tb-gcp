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

variable "root_id" {
  type        = string
  description = "id for the parent (organization or folder) where these projects will be created."
}

variable "billing_account_id" {
  type        = string
  description = "Id of billing account thi which projects will be assigned"
}

variable "shared_networking_project_name" {
  type        = string
  default     = "shared-networking"
  description = "Shared networking project name."
}

variable "shared_secrets_project_name" {
  type        = string
  default     = "shared-secrets"
  description = "Shared secrets project name."
}

variable "shared_telemetry_project_name" {
  type        = string
  default     = "shared-telemetry"
  description = "Shared telemetry project name."
}

variable "shared_operations_project_name" {
  type        = string
  default     = "shared-operations"
  description = "Shared operations project name."
}

variable "shared_billing_project_name" {
  type        = string
  default     = "shared-billing"
  description = "Shared billing project name."
}

variable "shared_ssp_project_name" {
  type        = string
  default     = "shared-ssp"
  description = "Shared ssp project name."
}

variable "tb_bastion_project_name" {
  type        = string
  default     = "tb-bastion"
  description = "Bastion project name."
}


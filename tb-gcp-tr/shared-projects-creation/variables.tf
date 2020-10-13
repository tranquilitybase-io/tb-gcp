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

variable "tb_discriminator" {
  type        = string
  description = "Random ID that is associated with the corresponding bootstrap project."
}

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

variable "shared_networking_project_custom_iam_bindings" {
  description = "List of custom IAM bindings that should be added to the shared networking project's policy. An item consists in a map containing a cloud identity member (such as group:name@example.com) and a IAM role (such as roles/compute.viewer)"
  type = list(object({
    member = string
    role   = string
  }))
}

variable "shared_telemetry_project_name" {
  type        = string
  default     = "shared-telemetry"
  description = "Shared telemetry project name."
}

variable "shared_itsm_project_name" {
  type        = string
  default     = "shared-itsm"
  description = "Shared itsm project name."
}

variable "shared_billing_project_name" {
  type        = string
  default     = "shared-billing"
  description = "Shared billing project name."
}

variable "shared_billing_project_custom_iam_bindings" {
  description = "List of custom IAM bindings that should be added to the shared billing project's policy. An IAM binding consists of a map containing a cloud identity `member` (such as group:name@example.com) and a IAM `role` (such as roles/bigquery.admin)"
  type = list(object({
    member = string
    role   = string
  }))
}

variable "shared_ec_project_name" {
  type        = string
  default     = "shared-ec"
  description = "Shared ec project name."
}

variable "shared_bastion_project_name" {
  type        = string
  default     = "shared-bastion"
  description = "Bastion project name."
}

variable "labels" {
  type        = map(string)
  description = "Labels to assign to resources."
}
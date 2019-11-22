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

variable "dependency_values" {
  description = "Placeholder for values the module depends on."
  type = "list"
}

variable "project_id" {
  description = "Project Id."
}

variable "region" {
  description = "The region to host the compute instance in"
}

variable "service_account_email" {
  type        = "string"
  description = "Service account to associate to the compute instance"
}

variable "machine_type" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "subnetwork" {
  type = "string"
}

variable "scopes" {
  type = "list"
}

variable "source_cidr" {
  type = "list"
}

variable "image" {
  type = "string"
}

variable "metadata_startup_script" {
  type = "string"
}

variable "tb_discriminator" {
  type = "string"
  description = "sufix added to the names/IDs such elements like Tranquility Base folder, Bootstrap project what allows their coexistence with other sibling TBase instances within the same Organisation/Folder. Example: 'uat', 'dev-am', ''. For the empty value no suffix will be added (thus production ready)."
}

variable "lz_branch" {
  type = "string"
  description = "branch name used during github cloning of Landing Zone repo (eg. tb-gcp-tr) for building Landing Zone infrastructure via Bootstrap terraform host. Default value is 'master'"
}

variable "terraform_state_bucket_name" {
  type = "string"
}

locals {
  project_id = "${data.google_client_config.this.project}"
}

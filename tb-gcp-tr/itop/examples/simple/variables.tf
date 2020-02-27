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

# Mandatory variables
variable "region" {
  type        = string
  description = "The Region"
}

variable "region_zone" {
  type        = string
  description = "The Zone"
}

variable "host_project_id" {
  type        = string
  description = "The host project where the aggregated logs will live."
}

variable "database_user_name" {
  type        = string
  description = "The database username name"
}

variable "database_user_password" {
  type        = string
  description = "The database name"
}

variable "k8_cluster_name" {
  type        = string
  description = "The k8 cluster this runs on"
}

variable "itop_chart_local_path" {
  type        = string
  description = "The path of where the itop chart is on the local system"
}


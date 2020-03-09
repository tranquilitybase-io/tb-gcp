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

variable "k8_cluster_name" {
  type        = string
  description = "The k8 cluster this runs on"
}

# Optional Variables
variable "database_version" {
  type        = string
  default     = "MYSQL_5_7"
  description = "The database to use"
}

variable "database_tier" {
  type        = string
  default     = "db-f1-micro"
  description = "The instance tier based on machine-type"
}

variable "database_instance_name" {
  type        = string
  default     = "itop-db-instance"
  description = "The database instance name"
}

variable "dependency_vars" {
  default     = ""
  description = "Should be set to a google_container_node_pool variable value"
  type        = string
}

variable "itop_namespace" {
  type        = string
  default     = "itop"
  description = "The namespace to deploy the itop"
}

variable "itop_chart_local_path" {
  type        = string
  default     = "helm"
  description = "The path of where the itop chart is on the local system"
}

variable "itop_replica_count" {
  type        = string
  default     = "1"
  description = "itop deployment replica count"
}

variable "itop_image_repository" {
  type        = string
  default     = "vbkunin/itop"
  description = "The itop image"
}

variable "itop_image_tag" {
  type        = string
  default     = "2.6.1-base"
  description = "The image version tag"
}

variable "cloudsql_proxy_sa_name" {
  type        = string
  default     = "cloudsql-proxy-sa"
  description = "The Cloud SQL Proxy service account used to access the database"
}


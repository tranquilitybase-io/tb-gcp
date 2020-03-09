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

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "url_map" {
  description = "A reference (self_link) to the url_map resource to use."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "ssl_certificates" {
  description = "List of SSL cert self links. Required if 'enable_ssl' is 'true'."
  type        = list(string)
  default     = []
}

variable "create_dns_entries" {
  description = "If set to true, create a DNS A Record in Cloud DNS for each domain specified in 'custom_domain_names'."
  type        = string
  default     = "false"
}

variable "custom_domain_names" {
  description = "List of custom domain names."
  type        = list(string)
  default     = []
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Records specified in 'var.custom_domain_names'. Only used if 'var.create_dns_entries' is true."
  type        = string
  default     = "replace-me"
}

variable "dns_record_ttl" {
  description = "The time-to-live for the site A records (seconds)"
  type        = string
  default     = "300"
}


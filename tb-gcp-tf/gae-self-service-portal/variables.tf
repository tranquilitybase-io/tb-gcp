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
variable "bucket_name" {
  type    = string
  default = "tb-ui"
}

variable "bucket_location" {
  description = "Location of the bucket that will store the static website"
  default     = "EU"
}

variable "project_id" {
  description = "ID of the project where the bucket will be created"
}

variable "bucket_storage_class" {
  description = "Storage class of the bucket that will store the static website"
  default     = "MULTI_REGIONAL"
}

variable "bucket_versioning" {
  description = "Enable versioning for the bucket that will store the static website"
  default     = false
}

variable "main_page_suffix" {
  description = "bucket's directory index where missing objects are treated as potential directories"
  default     = "index.html"
}

variable "not_found_page" {
  description = "The custom object to return when a requested resource is not found"
  default     = "404.html"
}

variable "source_bucket" {
  description = "The name of the bucket where to find files to be uploaded to newly created bucket"
  type        = string
  default     = ""
}

variable "gae-service" {
  description = "Google Appengine Service hosting Self Service Portal Angular application"
  default     = "default"
}

variable "gae-runtime" {
  description = "Runtime environment for Google Appengine Application"
  default     = "python27"
}

variable "gae-login-required" {
  description = "Lock Appengine service behind IAM"
  default     = "LOGIN_REQUIRED"
}

variable "ui-dist-dir" {
  description = "Directory to serve static files: index.html"
  default     = "tb-self-service-portal"
}

variable "ec-ui-zip" {
  default = "ec-ui.zip"
}

variable "gae-version" {
  description = "Version of Appengine Application"
  default     = "v1"
}

variable "ec_gke_dependency" {
  description = "Flag to control whether EC GKE cluster has been created"
}

variable "endpoint_file" {
  description = "JSON file containing IP address of EC GKE load balancer"
}


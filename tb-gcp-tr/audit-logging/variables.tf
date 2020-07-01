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

variable "region" {
    type    = "string"
    default = ""
}
variable "root_id" {
    type    = "string"
    default = ""
}
variable "logging_project_id" {
    type    = "string"
    default = ""
}
variable "services" {
    type    = "string"
    default = "allServices"
}
variable "location" {
    type    = "string"
    default = "EUROPE-WEST2"
}
variable "changestorageage" {
    type    = "string"
    default = "30"
}
variable "storageclass" {
    type    = "string"
    default = "NEARLINE"
}
variable "deleteage" {
    type    = "string"
    default = "365"
}
variable "bucketprefix" {
    type    = "string"
    default = "auditlogbucket-"
}
variable "labelfuction" {
    type    = "string"
    default = "bucket_to_store_root_folder_audit_logs"
}
variable "sinkname" {
    type    = "string"
    default = "log_sink_1"
}
variable "randomidlen" {
    type    = "string"
    default = "6"
}

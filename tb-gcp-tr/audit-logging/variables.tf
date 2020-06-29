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
    default = ""
}
variable "root_id" {
    default = ""
}
variable "logging_project_id" {
    default = ""
}
variable "logprojectid" {
    default = ""
}
variable "services" {
    default = "allServices"
}
variable "location" {
    default = "EUROPE-WEST2"
}
variable "changestorageage" {
    default = "30"
}
variable "storageclass" {
    default = "NEARLINE"
}
variable "deleteage" {
    default = "365"
}
variable "bucketprefix" {
    default = "logbucket-"
}
variable "labelfuction" {
    default = "bucket_to_store_logs"
}
variable "sinkname" {
    default = "log_sink"
}
variable "randomidlen" {
    default = "6"
}

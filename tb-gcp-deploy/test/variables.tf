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

## PROVIDER
variable "region" {
  type = "string"
  default = "europe-west2"
  description = "Region name."
}

variable "zone" {
  type = "string"
  default = "europe-west2-a"
  description = "Zone name in the region provided."
}

## COMPUTE_INSTANCE
variable "machine_name" {
  type = "string"
  default = "test-terraform-server"
  description = "The test Compute Instance name."
}

variable "project_id" {
  type = "string"
  description = "The test Project Id where tshe test GCE instance will be built."
}

variable "image" {
  type = "string"
  description = "The image from which to build test GCE instance. For possible values see: https://www.terraform.io/docs/providers/google/r/compute_instance.html#image"
}


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

variable "service_projects_number" {
  type        = string
  default     = ""
  description = "Number of service projects attached to shared vpc host"
}

variable "service_project_ids" {
  type        = list(string)
  default     = []
  description = "Associated service projects to link with the host project."
}

variable "host_project_id" {
  type        = string
  default     = ""
  description = "Identifier for the host project to be used"
}

variable "ssp_project_id" {
  type        = string
  default     = ""
  description = "Identifier for the host project to be used"
}

variable "bastion_project_id" {
  type        = string
  default     = ""
  description = "Identifier for the host project to be used"
}

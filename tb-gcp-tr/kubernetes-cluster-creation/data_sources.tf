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

data "google_project" "shared-vpc" {
  project_id = "${var.sharedvpc_project_id}"
}

data "google_project" "cluster" {
  project_id = "${var.cluster_project_id}"
}

resource "null_resource" "shared_vpc_created" {
  triggers = {
    trigger_dependency = "${var.shared_vpc_dependency}"
  }
}

data "google_client_config" "default" {
}

/*
data "google_compute_zones" "available" {
  project = "${var.cluster_project_id}"
  region = "${var.region}"
}

data "google_container_engine_versions" "this" {
  project = "${var.cluster_project_id}"
  region = "${var.region}"
}
*/

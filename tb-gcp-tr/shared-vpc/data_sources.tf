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

/*data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

data "google_project" "service_projects" {
  count = "${length(var.service_project_ids)}"
  project_id = "${element(var.service_project_ids, count.index)}"
}

# data "google_compute_network" "shared-vpc" {
#   name     = "${var.sharedvpc_network}"
#   project  = "${var.sharedvpc_project_id}"
# }

# data "google_compute_subnetwork" "cluster" {
#   name     = "${var.cluster_subnetwork}"
#   project  = "${var.sharedvpc_project_id}"
#   region   = "${var.region}"
# }*/

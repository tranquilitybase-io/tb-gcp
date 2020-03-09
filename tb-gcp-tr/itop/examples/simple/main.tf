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

# Setup of folders in empty/new org

module "itop-on-gke" {
  source                 = "../../"
  host_project_id        = var.host_project_id
  region                 = var.region
  region_zone            = var.region_zone
  database_user_name     = var.database_user_name
  database_user_password = var.database_user_password
  k8_cluster_name        = var.k8_cluster_name
  itop_chart_local_path  = var.itop_chart_local_path
}


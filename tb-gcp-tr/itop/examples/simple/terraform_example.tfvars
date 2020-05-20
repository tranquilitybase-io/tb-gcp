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

# Copy this file as terraform.tfvars, then fill in the details before running terraform.
# e.g.
# cp terraform.tfvars terraform_example.tfvars

region = "us-central1"

region_zone = "us-central1-a"

host_project_id = "[your_host_proj_id]"

database_user_name = "itop"

database_user_password = "itop"

k8_cluster_name = "gke-istio"

itop_chart_local_path = "../../helm"


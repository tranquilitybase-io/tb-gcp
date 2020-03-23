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

host_project_id = "shared-vpc-11111"

service_project_ids = ["infra-services-11111"]

standard_network_subnets = [
    {
        Name = "itsm"
        CIDR = "10.0.1.0/24"
    },
    {
        Name = "secrets"
        CIDR = "10.0.2.0/24"
    },
    {
        Name = "transit"
        CIDR = "10.0.0.0/24"
    }
]

gke_pod_network_name = "gke-pod-network"
gke_service_network_name = "gke-service-network"

gke_network_subnets = [
    {
        Name = "cicd"
        node_cidr = "10.0.10.0/24"
        pod_cidr = "10.10.0.0/17"
        service_cidr = "10.10.128.0/20"
    }
]

create_nat_gateway = true

tags = {
    owner = "example owner"
    environment = "dev"
    terraform = "true"
}
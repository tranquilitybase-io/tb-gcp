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

terraform {
  backend "gcs" {
    prefix = "terraform/bastion"
    #terraform init -backend-config="credentials=[PATH]" -backend-config="bucket=[bucket_name]"
    #bucket= ""
    #credentials = ""
  }
}

provider "google" {
  project     = var.bastion_project_id
  region      = var.region
  credentials = file(var.credentials_file)
  version = "~> 2.5"
}

# separate provider needed for creation of firewall rules in sharedvpc project
provider "google" {
  alias       = "shared-vpc"
  project     = var.sharedvpc_project_id
  region      = var.region
  credentials = file(var.credentials_file)
  version = "~> 2.5"
}

provider "google" {
  region = "${var.region}"
  version = "~> 3.17"
  alias = "google-3"
}

provider "google-beta" {
  region  = "${var.region}"
  version = "~> 3.17"
  alias = "google-beta-3"
}


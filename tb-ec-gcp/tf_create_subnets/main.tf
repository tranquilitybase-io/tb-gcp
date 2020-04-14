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

provider "google" {
  version = "~> 2.5"
  project = "${var.shared_networking_id}"
  region = "${var.region}"
}

provider "google" {
  project = "${var.shared_networking_id}"
  region = "${var.region}"
  version = "~> 3.17"
  alias = "google-3"
}

provider "google-beta" {
  project = "${var.shared_networking_id}"
  region  = "${var.region}"
  version = "~> 3.17"
  alias = "google-beta-3"
}


terraform {
  backend "gcs" {
    # The bucket name below is overloaded at every run with
    # `-backend-config="bucket=${bucket_name}"` parameter
    bucket  = "dummybucketname"
  }
}

/*
Create multiple subnets in #var.shared_networking_id
Additionaly base on google_compute_subnetwork.ip_cidr_range resource creates 2 secondary_ip_ranges:
 - gke-pods-snet
 - gke-services-snet
Above subnets are calculated base on main subnet CIDR.
Example
ip_cidr_range - 10.0.1.0/24
secondary_ip_range-1:
  - gke-pods-snet
  - 10.1.0.0/17
secondary_ip_range-2:
  - gke-services-snet
  - 10.1.128.0/20
*/
resource "google_compute_subnetwork" "application" {
  count = "${length(var.free_subnet_cidrs)}"
  name = "${var.subnets-name[count.index]}"
  project = "${var.shared_networking_id}"
  ip_cidr_range = "${var.free_subnet_cidrs[count.index]}"
  region = "${var.region}"
  network = "${data.google_compute_network.shared.self_link}"
  secondary_ip_range {
    range_name = "gke-pods-snet"
    ip_cidr_range = "${cidrsubnet(join("/", list(element(split("/", var.free_subnet_cidrs[count.index]), 0), var.default_netmask)),
     (17 - var.default_netmask),
     ((element(split(".", var.free_subnet_cidrs[count.index]),  ceil((element(split("/", var.free_subnet_cidrs[count.index]) , 1)/8.0) - 1)))*2)
     )}"
  }
  secondary_ip_range {
    range_name = "gke-services-snet"
    ip_cidr_range = "${cidrsubnet(join("/", list(element(split("/", var.free_subnet_cidrs[count.index]), 0), var.default_netmask)),
     (20 - var.default_netmask),
     ((element(split(".", var.free_subnet_cidrs[count.index]),  ceil((element(split("/", var.free_subnet_cidrs[count.index]) , 1)/8.0) - 1))*16) + 8))}"
  }
}

resource "local_file" "ip-ranges" {
  content     = "${join(",", google_compute_subnetwork.application.*.name)}"
  filename = "${path.module}/subnet_names"
}
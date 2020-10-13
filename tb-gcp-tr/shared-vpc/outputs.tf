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

/*output "subnet_uris" {
    description = "self-link/uri for any subnetworks created by this module."
    value = ["${concat(google_compute_subnetwork.standard.*.self_link, google_compute_subnetwork.gke.*.self_link)}"]
}

output "router_uri" {
    description = "self-link/uri for the router created by this module"
    value = "${google_compute_router.router.self_link}"
}*/

output "gke_subnetwork_ids" {
  value = join(",", google_compute_subnetwork.gke.*.id)
}

output "bastion_subnetwork_name" {
  value = google_compute_subnetwork.shared-bastion-subnetwork.name
}

output "nat_static_ip" {
  value = google_compute_address.static.address
}

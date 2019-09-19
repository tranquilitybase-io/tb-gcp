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

# DEPLOY A HTTP LOAD BALANCER
# This module deploys a HTTP(S) Cloud Load Balancer

# CREATE A PUBLIC IP ADDRESS

resource "google_compute_global_address" "default" {
  project      = "${var.project}"
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# CREATE FORWARDING RULE AND PROXY

resource "google_compute_target_http_proxy" "http" {
  project = "${var.project}"
  name    = "${var.name}-http-proxy"
  url_map = "${var.url_map}"
}

resource "google_compute_global_forwarding_rule" "http" {
  project    = "${var.project}"
  name       = "${var.name}-http-rule"
  target     = "${google_compute_target_http_proxy.http.self_link}"
  ip_address = "${google_compute_global_address.default.address}"
  port_range = "80"

  depends_on = ["google_compute_global_address.default"]
}

# IF DNS ENTRY REQUESTED, CREATE A RECORD POINTING TO THE PUBLIC IP OF THE CLB

resource "google_dns_record_set" "dns" {
  project = "${var.project}"
  count   = "${var.create_dns_entries ? length(var.custom_domain_names) : 0}"

  name = "${element(var.custom_domain_names, count.index)}"
  type = "A"
  ttl  = "${var.dns_record_ttl}"

  managed_zone = "${var.dns_managed_zone_name}"

  rrdatas = ["google_compute_global_address.default.address"]
}


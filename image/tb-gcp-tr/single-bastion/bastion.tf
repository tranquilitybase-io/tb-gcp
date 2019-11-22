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

resource "google_compute_instance" "bastion" {
  #uncomment below to match the no of zones
  #count        = "${length(data.google_compute_zones.available.names)}"
  name = "${var.bastion_name}"

  machine_type = "${var.bastion_machine_type}"
  zone         = "${data.google_compute_zones.available.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.debian9.self_link}"
    }
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.bastion.self_link}"

    access_config {
      // REQUIRED TO ALLOW SSH
    }
  }

  metadata_startup_script = "${data.template_file.startup-script.rendered}"

  service_account {
    email = "${google_service_account.bastion.email}"

    scopes = [
      "userinfo-email",
      "compute-ro",
      "storage-ro",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/projecthosting",
    ]
  }

  tags = [
    "remote-mgmt",
  ]

  depends_on = ["google_service_account.bastion"]
}

resource "google_compute_firewall" "bastion" {
  provider    = "google.shared-vpc"
  name        = "remote-mgmt"
  network     = "${data.google_compute_network.shared-vpc.self_link}"
  description = "Allow inbound SSH"
  direction   = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.bastion_source_cidr}"
  target_tags   = ["remote-mgmt"]
}

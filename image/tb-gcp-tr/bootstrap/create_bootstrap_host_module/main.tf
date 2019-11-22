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

resource "null_resource" "module_dependencies" {
  triggers = {
    dependency_values = "${join(",", var.dependency_values)}"
  }
}

resource "google_compute_instance" "this" {
  project = "${var.project_id}"
  name = "${var.name}"
  machine_type = "${var.machine_type}"
  
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
  }

  metadata_startup_script = "${data.template_file.startup-script.rendered}"

  service_account {
    email = "${var.service_account_email}"
    scopes = "${var.scopes}"
  }

  tags = [
    "remote-mgmt",
  ]

  depends_on = ["null_resource.module_dependencies"]
}

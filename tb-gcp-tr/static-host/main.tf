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

# CREATE GCP BUCKET TO STORE THE WEBSITE CONTENT

resource "google_storage_bucket" "UI_bucket" {
  name = "${var.bucket_name}-${var.project_id}"
  location = "${var.bucket_location}"
  project = "${var.project_id}"
  storage_class = "${var.bucket_storage_class}"
  force_destroy = "false"

  versioning {
    enabled = "${var.bucket_versioning}"
  }

  website {
    main_page_suffix = "${var.main_page_suffix}"
    not_found_page = "${var.not_found_page}"
  }
}

resource "google_storage_default_object_acl" "default_obj_acl" {
  bucket = "${google_storage_bucket.UI_bucket.name}"
  role_entity = ["${var.role_entity}"]

}

# CREATE LOADBALANCER TO GET EXTERNAL IP AND ACCESS TO THE BUCKET

resource "google_compute_backend_bucket" "static" {
  project = "${var.project_id}"

  name        = "${var.bucket_name}-backend-bucket"
  bucket_name = "${google_storage_bucket.UI_bucket.name}"
}

resource "google_compute_url_map" "urlmap" {
  project = "${var.project_id}"

  name        = "${var.bucket_name}-url-map"
  description = "URL map for ${var.bucket_name}"

  default_service = "${google_compute_backend_bucket.static.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "all"
  }

  path_matcher {
    name            = "all"
    default_service = "${google_compute_backend_bucket.static.self_link}"
  }
}

module "load_balancer" {
  source = "../http-load-balancer"
  project = "${var.project_id}"
  name = "${var.bucket_name}"
  url_map = "${google_compute_url_map.urlmap.self_link}"

}

# PUSH CONTENT TO THE BUCKET

resource "null_resource" "upload_to_static_host" {
  count = "${var.source_bucket == "" ? 0 : 1}"
  provisioner "local-exec" {
    command = "gsutil rsync -r gs://${var.source_bucket} gs://${google_storage_bucket.UI_bucket.name}"
  }

  provisioner "local-exec" {
    command = "gsutil rm -r gs://${google_storage_bucket.UI_bucket.name}/*"
    when    = "destroy"
  }

  depends_on = ["google_storage_bucket.UI_bucket", "google_storage_default_object_acl.default_obj_acl"]
}



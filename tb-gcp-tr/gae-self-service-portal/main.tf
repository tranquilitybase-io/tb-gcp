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

resource "google_storage_bucket" "ssp-ui-static-files" {
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

resource "google_storage_default_object_acl" "ssp-ui-static-files-obj-acl" {
  bucket = "${google_storage_bucket.ssp-ui-static-files.name}"
  role_entity = ["${var.role_entity}"]

}

# CREATE LOADBALANCER TO GET EXTERNAL IP AND ACCESS TO THE BUCKET
resource "google_compute_backend_bucket" "ssp-create-backend-bucket" {
  project = "${var.project_id}"

  name = "${google_storage_bucket.ssp-ui-static-files.name}-backend-bucket"
  bucket_name = "${google_storage_bucket.ssp-ui-static-files.name}"
}

resource "google_compute_url_map" "ssp-bucket-url-map" {
  project = "${var.project_id}"

  name = "${google_storage_bucket.ssp-ui-static-files.name}-url-map"
  description = "URL map for ${var.bucket_name}"

  default_service = "${google_compute_backend_bucket.ssp-create-backend-bucket.self_link}"

  host_rule {
    hosts = ["*"]
    path_matcher = "all"
  }

  path_matcher {
    name = "all"
    default_service = "${google_compute_backend_bucket.ssp-create-backend-bucket.self_link}"
  }
}

module "load_balancer" {
  source = "../http-load-balancer"
  project = "${var.project_id}"
  name = "${google_storage_bucket.ssp-ui-static-files.name}"
  url_map = "${google_compute_url_map.ssp-bucket-url-map.self_link}"

}

# PUSH CONTENT TO THE BUCKET
resource "null_resource" "sync-ssp-ui-buckets" {
  count = "${var.source_bucket == "" ? 0 : 1}"
  provisioner "local-exec" {
    command = "gsutil rsync -r gs://${var.source_bucket} gs://${google_storage_bucket.ssp-ui-static-files.name}"
  }

  provisioner "local-exec" {
    command = "gsutil rm -r gs://${google_storage_bucket.ssp-ui-static-files.name}/*"
    when = "destroy"
  }

  depends_on = [
    "google_storage_bucket.ssp-ui-static-files",
    "google_storage_default_object_acl.ssp-ui-static-files-obj-acl"]
}

resource "null_resource" "ssp_gke_cluster_endpoint_retrieved" {
  triggers = {
    ssp_gke_cluster = "${var.ssp_gke_dependency}"
  }
}

resource "null_resource" "copy-endpoint-meta" {
  provisioner "local-exec" {
    command = "cp ${var.endpoint_file} ${var.ui-source-local}/dist/tb-self-service-portal/assets/"

  }
  depends_on = ["null_resource.ssp_gke_cluster_endpoint_retrieved"]
}

data "archive_file" "archive-ssp-ui" {
  type = "zip"
  source_dir = "${var.ui-source-local}/dist/"
  output_path = "${var.ui-source-local}/${var.ssp-ui-zip}"

  depends_on = [
    "null_resource.copy-endpoint-meta"]
}

resource "google_storage_bucket_object" "ssp-ui-upload" {
  name = "${var.ssp-ui-zip}"
  source = "${var.ui-source-local}/${var.ssp-ui-zip}"
  bucket = "${google_storage_bucket.ssp-ui-static-files.name}"
  depends_on = [
    "null_resource.copy-endpoint-meta",
    "google_storage_bucket.ssp-ui-static-files", "data.archive_file.archive-ssp-ui"]
}
# CREATE GAE STANDARD APPLICATION TO HOST SSP UI
resource "google_app_engine_standard_app_version" "ssp-ui-deploy" {
  version_id = "${var.gae-version}"
  service = "${var.gae-service}"
  runtime = "${var.gae-runtime}"
  project = "${var.project_id}"
  threadsafe = true
  noop_on_destroy = true
  handlers {
    url_regex = "/"
    login = "${var.gae-login-required}"
    static_files = [
      {
        path = "${var.ui-dist-dir}/index.html"
        upload_path_regex = "${var.ui-dist-dir}/index.html"
      }]
  }
  handlers {
    url_regex = "/(.*)$"
    login = "${var.gae-login-required}"
    static_files = [
      {
        path = "${var.ui-dist-dir}/\\1"
        upload_path_regex = "${var.ui-dist-dir}/.*"
      }]
  }
  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.ssp-ui-static-files.name}/${var.ssp-ui-zip}"
    }
  }
  depends_on = ["google_storage_bucket_object.ssp-ui-upload"]
}


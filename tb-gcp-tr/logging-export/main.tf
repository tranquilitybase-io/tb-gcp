resource "null_resource" "api_enabled" {
  triggers = {
    vpc_name = var.apis_dependency
  }
}

locals {
  log_filter                = "-unicorn (-Fdata_access) AND -unicorn (-Factivity) AND -unicorn (-Fsystem_event)"
  applications_bucket_id    = "${var.applications_bucket_name}-${var.tb_discriminator}"
  shared_services_bucket_id = "${var.shared_services_bucket_name}-${var.tb_discriminator}"
}

module "logging_buckets" {
  source               = "terraform-google-modules/cloud-storage/google"

  version              = "~> 1.6"
  project_id           = var.shared_telemetry_project_name
  names                = [local.applications_bucket_id, local.shared_services_bucket_id]
  prefix               = var.prefix
  storage_class        = var.storage_class
  lifecycle_rules      = var.lifecycle_rule
  location             = var.location
  encryption_key_names = var.encryption_key_names

}

resource "google_storage_bucket_iam_binding" "applications_binding" {
  bucket = module.logging_buckets.names_list[0]
  role   = var.audit_iam_role
  members = [
    module.applications_sink.unique-writer-identity
  ]
}
resource "google_storage_bucket_iam_binding" "shared_services_binding" {
  bucket = module.logging_buckets.names_list[1]
  role   = var.audit_iam_role
  members = [
    module.shared_services_sink.unique-writer-identity
  ]
}

module "applications_sink" {
  source = "../logging-folder-sink"

  name             = var.applications_sink_name
  folder_id        = var.applications_id
  filter           = var.log_filter != "" ? var.log_filter : local.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${module.logging_buckets.names_list[0]}"
}

module "shared_services_sink" {
  source = "../logging-folder-sink"

  name             = var.shared_services_sink_name
  folder_id        = var.shared_services_id
  filter           = var.log_filter != "" ? var.log_filter : local.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${module.logging_buckets.names_list[1]}"
}
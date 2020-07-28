locals {
  log_filter                = "NOT (logName=folders/${var.shared_services_id}/logs/cloudaudit.googleapis.com%2Factivity)  AND (logName=folders/${var.shared_services_id}logs/cloudaudit.googleapis.com%2Fsystem_event) AND (logName=folders/${var.applications_id}/logs/cloudaudit.googleapis.com%2Factivity)  AND (logName=folders/${var.applications_id}logs/cloudaudit.googleapis.com%2Fsystem_event)"
  applications_bucket_id    = "${var.applications_bucket_name}-${var.tb_discriminator}"
  shared_services_bucket_id = "${var.shared_services_bucket_name}-${var.tb_discriminator}"
}

module "logging_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 1.6"
  project_id = var.shared_telemetry_project_name
  names      = [local.applications_bucket_id, local.shared_services_bucket_id]
  prefix     = "logging"
  location   = var.region
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

locals {
  log_filter = "NOT (logName=folders/${var.shared_services_id}/logs/cloudaudit.googleapis.com%2Factivity)  AND (logName=folders/${var.shared_services_id}logs/cloudaudit.googleapis.com%2Fsystem_event) AND (logName=folders/${var.applications_id}/logs/cloudaudit.googleapis.com%2Factivity)  AND (logName=folders/${var.applications_id}logs/cloudaudit.googleapis.com%2Fsystem_event)"
}

module "shared_services_log_bucket" {
  source = "github.com/tranquilitybase-io/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v1.7.0"

  name       = "${var.shared_services_bucket_name}-${var.tb_discriminator}"
  project_id = var.shared_telemetry_project_name
  location   = var.region
  lifecycle_rule = var.lifecycle_rule
}

module "applications_log_bucket" {
  source = "github.com/tranquilitybase-io/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v1.7.0"

  name       = "${var.applications_bucket_name}-${var.tb_discriminator}"
  project_id = var.shared_telemetry_project_name
  location   = var.region
  lifecycle_rule = var.lifecycle_rule
}

module "applications_sink" {
  source = "../logging-folder-sink"

  name             = var.applications_sink_name
  folder_id        = var.applications_id
  filter           = var.log_filter != "" ? var.log_filter : local.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${applications_log_bucket.name}"
}

module "shared_services_sink" {
  source = "../logging-folder-sink"

  name             = var.shared_services_sink_name
  folder_id        = var.shared_services_id
  filter           = var.log_filter != "" ? var.log_filter : local.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${shared_services_log_bucket.name}"
}




locals {
  log_filter                = "-unicorn (-Fdata_access) AND -unicorn (-Factivity) AND -unicorn (-Fsystem_event)"
  applications_bucket_id    = "${var.applications_bucket_name}-${var.tb_discriminator}"
  shared_services_bucket_id = "${var.shared_services_bucket_name}-${var.tb_discriminator}"
}

module "logging_buckets" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "~> 1.6"
  project_id      = var.shared_telemetry_project_name
  names           = [local.applications_bucket_id, local.shared_services_bucket_id]
  prefix          = var.prefix
  storage_class   = var.storage_class
  lifecycle_rules = var.lifecycle_rule
  location        = var.location
}

# module "audit-log-writer-binding_apps" {
#   source = "../project-iam-binding-creator"

#   project = var.shared_telemetry_project_name
#   members = module.applications_sink.unique-writer-identity
#   role    = var.audit_iam_role
# }

# module "audit-log-writer-binding_shared" {
#   source = "../project-iam-binding-creator"

#   project = var.shared_telemetry_project_name
#   members = module.shared_services_sink.unique-writer-identity
#   role    = var.audit_iam_role
# }

# data "google_iam_policy" "object_creator" {
#   binding {
#     role = var.audit_iam_role
#     members = [
#       module.shared_services_sink.unique-writer-identity,
#       module.applications_sink.unique-writer-identity
#     ]
#   }
# }

resource "google_storage_bucket_iam_binding" "applications_binding" {
  bucket = module.logging_buckets.names_list[0]
  role = var.audit_iam_role
  members = [
    module.applications_sink.unique-writer-identity
  ]
}
resource "google_storage_bucket_iam_binding" "shared_services_binding" {
  bucket = module.logging_buckets.names_list[1]
  role = var.audit_iam_role
  members = [
    module.shared_services_sink.unique-writer-identity
  ]
}

# resource "google_storage_bucket_iam_policy" "apps_bucket_object_creator_policy" {
#   bucket      = module.logging_buckets.names_list[0]
#   policy_data = data.google_iam_policy.object_creator.policy_data
# }

# resource "google_storage_bucket_iam_policy" "ss_bucket_object_creator_policy" {
#   bucket      = module.logging_buckets.names_list[1]
#   policy_data = data.google_iam_policy.object_creator.policy_data
# }

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
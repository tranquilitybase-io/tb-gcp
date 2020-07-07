resource "google_logging_folder_sink" "logging-folder-sink" {
  name             = var.name
  folder           = var.folder_id
  filter           = var.filter
  include_children = var.include_children
  destination      = var.destination
}

resource "google_folder_iam_member" "applications_folder_loggingConfigWriter_to_bootstrap-sa" {
  folder = var.applications_id
  member = format("serviceAccount:bootstrap-sa@bootstrap-%s.iam.gserviceaccount.com", var.tb_discriminator)
  role   = "roles/logging.configWriter"
}

resource "google_folder_iam_member" "shared_services_folder_loggingConfigWriter_to_bootstrap-sa" {
  folder = var.shared_services_id
  member = format("serviceAccount:bootstrap-sa@bootstrap-%s.iam.gserviceaccount.com", var.tb_discriminator)
  role   = "roles/logging.configWriter"
}
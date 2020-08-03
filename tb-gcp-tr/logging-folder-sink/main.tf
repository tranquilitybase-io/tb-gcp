resource "google_logging_folder_sink" "logging-folder-sink" {
  name             = var.name
  folder           = var.folder_id
  filter           = var.filter
  include_children = var.include_children
  destination      = var.destination
}

resource "google_storage_bucket" "shared_services_log_bucket" {
  name     = "sharedserviceslogs-${var.tb_discriminator}"
  location = var.region
  project = "shared-telemetry-${var.tb_discriminator}"

  storage_class = var.storage_class[0]

  labels = {
    bucket_function = var.bucket_function[0]
  }

  lifecycle_rule {
    condition {
      age = var.age[var.lr_actions[0]]
    }
    action {
      type = var.lr_actions[0]
    }
  }

  lifecycle_rule {
    condition {
      age = var.age[var.lr_actions[1]]
    }
    action {
      type          = var.lr_actions[1]
      storage_class = var.storage_class[0]
    }
  }
}

resource "google_storage_bucket" "applications_log_bucket" {
  name     = "applicationslogs-${var.tb_discriminator}"
  location = var.region
  project = "shared-telemetry-${var.tb_discriminator}"

  storage_class = var.storage_class[0]

    labels = {
    bucket_function = var.bucket_function[1]
  }

  lifecycle_rule {
    condition {
      age = var.age[var.lr_actions[0]]
    }
    action {
      type = var.lr_actions[0]
    }
  }

  lifecycle_rule {
    condition {
      age = var.age[var.lr_actions[1]]
    }
    action {
      type          = var.lr_actions[1]
      storage_class = var.storage_class[0]
    }
  }
}

resource "google_logging_folder_sink" "applications_sink" {
  name                   = var.aggregated_export_sink_name[0]
  folder                 = "Applications"
  destination            = "storage.googleapis.com/${google_storage_bucket.applications_log_bucket.name}"
  filter                 = var.log_filter
  include_children       = true
  depends_on             = [google_storage_bucket.applications_log_bucket]
}

resource "google_logging_folder_sink" "shared_services_sink" {
  name                   = var.aggregated_export_sink_name[1]
  folder                 = "Shared Services"
  destination            = "storage.googleapis.com/${google_storage_bucket.shared_services_log_bucket.name}"
  filter                 = var.log_filter
  include_children       = true
  depends_on             = [google_storage_bucket.shared_services_log_bucket]
}
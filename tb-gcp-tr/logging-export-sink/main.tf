
# A bucket to store logs in
resource "google_storage_bucket" "shared_services_log_bucket" {
  name     = var.bucket_uid_name
  location = "europe-west1"

  storage_class = var.storage_class[0]

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

# A bucket to store logs in
resource "google_storage_bucket" "applications_log_bucket" {
  name     = var.bucket_uid_name
  location = "europe-west1"


  storage_class = var.storage_class[0]

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


resource "google_logging_folder_sink" "folder_sink" {
  name                   = var.aggregated_export_sink_name
  folder                 = "folders/"
  destination            = "storage.googleapis.com/${google_storage_bucket.shared_services_log_bucket.name}"
  filter                 = var.log_filter
  include_children       = true
}

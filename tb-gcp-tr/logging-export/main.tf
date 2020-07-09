
resource "google_storage_bucket" "shared_services_log_bucket" {
  name     = "sharedserviceslogs-${var.tb_discriminator}"
  location = var.bucket_location
  project  = var.shared_telemetry_project_name

  labels = {
    bucket_function = var.bucket_function
  }

  dynamic "lifecycle_rule" {
    for_each = [for c in var.lifecycle_rule : {
      age           = c.age
      type          = c.type
      storage_class = c.storage_class
    }]

    content {
      action {
        type          = lifecycle_rule.value.type
        storage_class = lifecycle_rule.value.storage_class
      }
      condition {
        age = lifecycle_rule.value.age
      }
    }
  }
}

resource "google_storage_bucket" "applications_log_bucket" {
  name     = "applicationslogs-${var.tb_discriminator}"
  location = var.bucket_location
  project  = var.shared_telemetry_project_name

  labels = {
    bucket_function = var.bucket_function
  }

  dynamic "lifecycle_rule" {
    for_each = [for c in var.lifecycle_rule : {
      age           = c.age
      type          = c.type
      storage_class = c.storage_class
    }]

    content {
      action {
        type          = lifecycle_rule.value.type
        storage_class = lifecycle_rule.value.storage_class
      }
      condition {
        age = lifecycle_rule.value.age
      }
    }
  }
}

module "applications_sink" {
  source = "../logging-folder-sink"

  name               = var.applications_sink_name
  folder_id          = var.applications_id
  filter             = var.log_filter
  include_children   = var.include_children
  destination        = "storage.googleapis.com/${google_storage_bucket.applications_log_bucket.name}"
  tb_discriminator   = var.tb_discriminator
  
}

module "shared_services_sink" {
  source = "../logging-folder-sink"

  name               = var.shared_services_sink_name
  folder_id          = var.shared_services_id
  filter             = var.log_filter
  include_children   = var.include_children
  destination        = "storage.googleapis.com/${google_storage_bucket.shared_services_log_bucket.name}"
  tb_discriminator   = var.tb_discriminator
}




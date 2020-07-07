
resource "google_storage_bucket" "shared_services_log_bucket" {
  name     = "sharedserviceslogs-${var.tb_discriminator}"
  location = var.region
  project  = var.shared_telemetry_project_name

  labels = {
    bucket_function = var.shared_services_sink_name
  }

  dynamic "lifecycle_rule" {
    for_each = [for c in var.lifecyclerule : {
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
  location = var.region
  project  = var.shared_telemetry_project_name

  labels = {
    bucket_function = format(var.shared_services_sink_name)
  }

  dynamic "lifecycle_rule" {
    for_each = [for c in var.lifecyclerule : {
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
  source = "../sink"

  name             = var.applications_sink_name
  folder_id        = var.applications_id
  filter           = var.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${google_storage_bucket.applications_log_bucket.name}"
  tb_discriminator = var.tb_discriminator
  shared_services_id = var.shared_services_id
  applications_id = var.applications_id
}

module "shared_services_sink" {
  source = "../sink"

  name             = var.shared_services_sink_name
  folder_id        = var.shared_services_id
  filter           = var.log_filter
  include_children = var.include_children
  destination      = "storage.googleapis.com/${google_storage_bucket.shared_services_log_bucket.name}"
  tb_discriminator = var.tb_discriminator
  applications_id  = var.applications_id
  shared_services_id = var.shared_services_id
}

resource "google_storage_bucket_iam_binding" "applications_log_sink_bucket_objectCreators" {
  bucket  = google_storage_bucket.applications_log_bucket.name
  members = [module.applications_sink.applications_writer_identity]
  role    = "roles/storage.objectCreator"
}

resource "google_storage_bucket_iam_binding" "shared_services_log_sink_bucket_objectCreators" {
  bucket  = google_storage_bucket.shared_services_log_bucket.name
  members = [module.shared_services_sink.shared_services_writer_identity]
  role    = "roles/storage.objectCreator"
}



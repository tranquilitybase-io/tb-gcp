variable "shared_services_sink_name" {
  description = "Name of the shared services sink."
  type        = string
  default     = "shared_services_sink"
}

variable "applications_sink_name" {
  description = "Name of the applications sink."
  type        = string
  default     = "applications_sink"
}

variable "lifecycle_rule" {
  description = "Time bound rules for moving and deleting the bucket."

  type = set(object({
    action    = map(string)
    condition = map(string)
  }))

  default = [{
    action = {
      type          = "Delete"
      storage_class = null
    }
    condition = {
      age = "365"
    }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = "30"
      }
  }]
}

variable "log_filter" {
  type        = string
  description = "Filter used for the logging sink."
  default     = ""
}

variable "tb_discriminator" {
  type        = string
  description = "Random Id assigned to the deployment."
}

variable "shared_telemetry_project_name" {
  type        = string
  description = "Shared telemetry project name."
}

variable "shared_services_id" {
  type        = string
  description = "Shared Services Folder Id"
}

variable "applications_id" {
  type        = string
  description = "Applications Folder Id"
}

variable "include_children" {
  type        = bool
  default     = true
  description = "Whether to include logs from child resources."
}

variable "bucket_function" {
  type        = string
  default     = "log_export"
  description = "Purpose of the bucket for label."
}

variable "shared_services_bucket_name" {
  type        = string
  description = "Name of the shared services bucket."
  default     = "shared_services_folder_logs"
}

variable "applications_bucket_name" {
  type        = string
  description = "Name of the applications bucket."
  default     = "applications_folder_logs"
}

variable "storage_class" {
  type        = string
  description = "Storage class for the bucket."
  default     = "REGIONAL"
}

variable "prefix" {
  type        = string
  description = "Prefix of the buckets to be created."
  default     = "logging"
}

variable "location" {
  type        = string
  description = "Zone or region that the bucket will be created in."
  default     = "EUROPE-WEST2"
}

variable "audit_iam_role" {
  description = "Give log writer permissions to create logs in bucket."
  default     = "roles/storage.admin"
}

variable "keys" {
  type        = list(string)
  description = ""
  default     = []
}
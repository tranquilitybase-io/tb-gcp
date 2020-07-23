
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
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
      age           = "30"
    }
    condition = {
      age                   = 30
      matches_storage_class = list("MULTI_REGIONAL,STANDARD,DURABLE_REDUCED_AVAILABILITY")
    }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age        = 365
        with_state = "ANY"
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

variable "region" {
  type        = string
  description = "Region for GCS Bucket"
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
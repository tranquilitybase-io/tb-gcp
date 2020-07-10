variable "bucket_location" {
  description = "Location that the bucket is created in."
  type        = string
}

variable "shared_services_sink_name" {
  description = "Name of the shared services sink."
  type        = string
  default     = "SharedServicesSink"
}

variable "applications_sink_name" {
  description = "Name of the applications sink"
  type        = string
  default     = "ApplicationsSink"
}

variable "lifecycle_rule" {
  description = "Time bound rules for moving and deleting the bucket."
  type        = list(map(string))

  default = [
    {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
      age           = "30"
    },
    {
      type          = "Delete"
      storage_class = ""
      age           = "365"
    }
  ]
}


variable "log_filter" {
  type        = string
  description = "Filter used for the logging sink."
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
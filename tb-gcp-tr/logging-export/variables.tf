

variable "shared_services_sink_name"{
  type = string
  default = "SharedServicesSink"
}

variable "applications_sink_name"{
  type = string
  default = "ApplicationsSink"
}

variable "lifecyclerule" {
  type = list(map(string))

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

variable "log_type" {
  type    = string
  default = "Logging"
}

variable "log_filter" {
  type    = string
  default = "NOT (logName=logs/cloudaudit.googleapis.com%2Fdata_access) NOT (logName=logs/cloudaudit.googleapis.com%2Factivity)  NOT (logs/cloudaudit.googleapis.com%2Fsystem_event)"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "tb_discriminator" {
  type = string
}

variable "shared_telemetry_project_name" {
  type        = string
  description = "Shared telemetry project name."
}

variable "shared_services_id" {
  type = string
}

variable "applications_id" {
  type = string
}

variable "include_children" {
  type = bool
  default = true
  
}

variable "bucket_function"{
  type = string
  default = "log_export"
}
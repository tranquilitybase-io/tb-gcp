
variable "aggregated_export_sink_name" {
  type    = list(string)
  default = ["applications_logging", "shared_services_loggging"]
}

variable "lr_actions" {
  type    = list(string)
  default = ["Delete", "SetStorageClass"]
}

variable "bucket_function" {
  type    = list(string)
  default = ["sharedservicesloggging", "applicationslogging"]

}

variable "age" {
  type = map
  default = {
    Delete          = "365"
    SetStorageClass = "30"
  }
} #

variable "storage_class" {
  type    = list(string)
  default = ["REGIONAL", "NEARLINE"]
}

variable "log_type" {
  type    = string
  default = "Logging"
}

variable "log_filter" {
  type    = string
  default = "NOT proto_payload.@type=\"type.googleapis.com/google.cloud.audit.AuditLog\" OR proto_payload.@type=\"type.googleapis.com/google.cloud.audit.SystemLog\""
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





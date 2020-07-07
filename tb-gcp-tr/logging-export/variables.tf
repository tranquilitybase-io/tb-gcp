

variable "shared_services_sink_name"{
  type = string
  default = "SharedServicesSink"
}

variable "applications_sink_name"{
  type = string
  default = "ApplicationsSink"
}

variable "bucket_function" {
  type    = list(string)
  default = ["sharedservicesloggging", "applicationslogging"]

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

variable "include_children" {
  type = bool
  default = true
  
}





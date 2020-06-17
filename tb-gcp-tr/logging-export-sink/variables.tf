
variable "project" {
  type    = string
  default = "tf-associate-prep"
}

variable "applications_log_bucket" {
  type        = string
  description = "Bucket name"
  default     = "applicationslogging-8374dfsdfttttnsa"
}

variable "shared_services_log_bucket" {
type        = string
  description = "Bucket name"
  default     = "sharedserviceslogging-8374dfsdfttttnsa"
}

variable "aggregated_export_sink_name" {
  type    = list(string)
  default = ["applications_logging","shared_services_loggging"]
}

variable "availability_zone_names" {
  type = map
  default = {
    europe-west1 = "europe-west1-b"
    us-central1  = "us-central1-b"
    asia-east2   = "asia-east2-c"
  }
}

variable "lr_actions" {
  type    = list(string)
  default = ["Delete", "SetStorageClass"]
}


variable "age" {
  type = map
  default = {
    Delete          = "365"
    SetStorageClass = "30"
  }
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
  default = "NOT audit OR system"
}

variable "region" {
  type    = string
  default = "europe-west1"
}




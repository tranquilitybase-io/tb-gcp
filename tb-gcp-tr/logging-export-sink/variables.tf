
variable "project" {
  type    = string
  default = "tf-associate-prep"
}

variable "bucket_uid_name" {
  type        = string
  description = "Bucket name"
  default     = "oiasjd-8374dfsdfttttnsa"
}

variable "aggregated_export_sink_name" {
  type    = string
  default = "folder_sink"
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




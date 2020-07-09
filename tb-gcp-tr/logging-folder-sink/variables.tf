
variable "sink_name" {
  description = ""
  type = string
}

variable "destination" {
  description = "The self_link URI of the destination resource (This is available as an output coming from one of the destination submodules)"
  type        = string
}

variable "filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The ID of the GCP resource in which you create the log sink. If var.parent_resource_type is set to 'project', then this is the Project ID (and etc)."
  type        = string
}

variable "shared_services_id" {
  description = ""
  type = string
}


variable "service_name" {
  type        = string
  description = "ID of the OVH public cloud project"
}

variable "region" {
  type        = string
  description = "Object storage region. Note this is the region without the datacentre number, e.g. UK rather than UK1"
  default     = "UK"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket to store PDS backups in. Must be unique within the region."
}

variable "retention_days" {
  type        = number
  description = "Number of days to keep overwritten versions of a backed up object"
  default     = 30
}

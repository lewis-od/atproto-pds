variable "hosted_zone_name" {
  type        = string
  description = "Name of the Route53 hosted zone to create the DNS records in"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of Route53 hosted zone to create the DNS records in"
}

variable "pds_subdomain" {
  type        = string
  description = "Subdomain of the hosted zone that will be used to access the PDS"
  default     = "pds"
}

variable "ttl" {
  type        = number
  description = "Time-to-live of the DNS records"
  default     = 300
}

variable "pds_ip_address" {
  type        = string
  description = "Public IP address of the PDS instance"
}

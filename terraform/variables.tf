# TODO: remove the DigitalOcean variables once the Droplet has been decommissioned
variable "digitalocean_token" {
  type        = string
  description = "Token for authenticating with the DO API"
}

variable "digitalocean_ssh_key_id" {
  type        = number
  description = "ID of the Digital Ocean SSH key to be added to the Droplet. Can be retrieved from https://api.digitalocean.com/v2/account/keys"
}

variable "droplet_region" {
  type        = string
  description = "Region to deploy the PDS Droplet in"
  default     = "lon1"
}

variable "ovh_project_id" {
  type        = string
  description = "ID of the OVH public cloud project. This is also the OpenStack tenant ID."
}

variable "ovh_application_key" {
  type        = string
  description = "Application key for the OVH API, created at https://api.ovh.com/createToken/"
}

variable "ovh_application_secret" {
  type        = string
  description = "Application secret for the OVH API"
  sensitive   = true
}

variable "ovh_consumer_key" {
  type        = string
  description = "Consumer key for the OVH API"
  sensitive   = true
}

variable "openstack_user_name" {
  type        = string
  description = "Username of the OpenStack user, from the openrc file downloaded when creating the user"
}

variable "openstack_password" {
  type        = string
  description = "Password of the OpenStack user"
  sensitive   = true
}

variable "ovh_compute_region" {
  type        = string
  description = "OVH region to deploy the PDS instance in"
  default     = "UK1"
}

variable "ovh_storage_region" {
  type        = string
  description = "OVH region to create the backup bucket in. Object storage regions omit the datacentre number."
  default     = "UK"
}

variable "ovh_flavor_name" {
  type        = string
  description = "Flavor of the PDS instance. See https://www.ovhcloud.com/en-gb/public-cloud/prices/"
  default     = "d2-2"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to install on the PDS instance"
}

variable "backup_bucket_name" {
  type        = string
  description = "Name of the OVH Object Storage bucket to store PDS backups in"
}

variable "cutover_dns_to_ovh" {
  type        = bool
  description = "Whether the PDS DNS records point at the OVH instance rather than the DigitalOcean Droplet. See docs/migration-do-to-ovh.md."
  default     = false
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
}

variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone name to use for Route 53 records. PDS will be hosted at pds.{hosted_zone_name}"
}

variable "resend_mx_record" {
  type        = string
  description = "MX record from Resend for 'send.' subdomain"
}

variable "resend_txt_record" {
  type        = string
  description = "TXT record value from Resend for 'send.' subdomain"
}

variable "resend_domainkey" {
  type        = string
  description = "TXT record value from Resend for 'resend._domainkey.' subdomain"
}

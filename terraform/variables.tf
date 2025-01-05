variable "digitalocean_token" {
  type        = string
  description = "Token for authenticating with the DO API"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
}

variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone name to use for Route 53 records. PDS will be hosted at pds.{hosted_zone_name}"
}

variable "droplet_region" {
  type = string
  description = "Region to deploy the PDS Droplet in"
  default = "lon1"
}

variable "digitalocean_ssh_key_id" {
  type        = number
  description = "ID of the Digital Ocean SSH key to be added to the Droplet. Can be retrieved from https://api.digitalocean.com/v2/account/keys"
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

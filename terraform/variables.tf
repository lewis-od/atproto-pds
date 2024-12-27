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

variable "digitalocean_ssh_key_id" {
  type        = number
  description = "ID of the Digital Ocean SSH key to be added to the Droplet"
}

variable "resend_mx_record" {
  type        = string
  description = "MX record from Resend"
}

variable "resend_txt_record" {
  type        = string
  description = "Resend TXT record for 'send.' subdomain"
}

variable "resend_domainkey" {
  type        = string
  description = "Resend domain key record"
}

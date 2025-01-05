variable "root_domain" {
  type        = string
  description = "The domain you'd like to verify in Resend"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of Route53 hosted zone to create the DNS records in"
}

variable "ttl" {
  type        = number
  description = "Time-to-live of the DNS records"
  default     = 300
}

variable "send_mx" {
  type        = string
  description = "MX record from Resend for 'send.' subdomain"
}

variable "send_txt" {
  type        = string
  description = "TXT record value from Resend for 'send.' subdomain"
}

variable "domainkey" {
  type        = string
  description = "TXT record value from Resend for 'resend._domainkey.' subdomain"
}

variable "dmarc" {
  type = object({
    percentage             = optional(number)           # pct
    forensic_report_email  = optional(string)           # ruf
    aggregate_report_email = optional(string)           # rua
    policy                 = string                     # p
    subdomain_policy       = optional(string)           # sp
    dkim_alignment_mode    = optional(string)           # adkim
    spf_alignment_mode     = optional(string)           # aspf
  })
  description = "DMARC record to create, see https://en.wikipedia.org/wiki/DMARC for more info"
  default     = { policy = "none" }
}

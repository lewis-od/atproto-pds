variable "percentage" {
  type    = number
  default = null

  validation {
    condition     = coalesce(var.percentage, 100) >= 0 && coalesce(var.percentage, 100) <= 100
    error_message = "Must be a valid percentage 0-100"
  }
}

variable "forensic_report_email" {
  type    = string
  default = null
}

variable "aggregate_report_email" {
  type    = string
  default = null
}

variable "policy" {
  type    = string
  default = "none"

  validation {
    condition     = contains(["none", "quarantine", "reject"], var.policy)
    error_message = "Must be one of: none, quarantine, reject"
  }
}

variable "subdomain_policy" {
  type    = string
  default = null

  validation {
    condition     = contains(["none", "quarantine", "reject"], coalesce(var.subdomain_policy, "none"))
    error_message = "Must be one of: none, quarantine, reject"
  }
}

variable "dkim_alignment_mode" {
  type    = string
  default = null

  validation {
    condition     = contains(["r", "s"], coalesce(var.dkim_alignment_mode, "r"))
    error_message = "Must be one of: r, s"
  }
}

variable "spf_alignment_mode" {
  type    = string
  default = null

  validation {
    condition     = contains(["r", "s"], coalesce(var.spf_alignment_mode, "r"))
    error_message = "Must be one of: r, s"
  }
}

locals {
  v     = "v=DMARC1;"
  pct   = var.percentage != null ? "pct=${var.percentage};" : ""
  ruf   = var.forensic_report_email != null ? "ruf=mailto:${var.forensic_report_email};" : ""
  rua   = var.aggregate_report_email != null ? "rua=mailto:${var.aggregate_report_email};" : ""
  p     = "p=${var.policy};"
  sp    = var.subdomain_policy != null ? "sp=${var.subdomain_policy};" : ""
  adkim = var.dkim_alignment_mode != null ? "adkim=${var.dkim_alignment_mode};" : ""
  aspf  = var.spf_alignment_mode != null ? "aspf=${var.spf_alignment_mode};" : ""
}

output "dmarc_record" {
  value = "${local.v}${local.pct}${local.ruf}${local.rua}${local.p}${local.sp}${local.adkim}${local.aspf}"
}

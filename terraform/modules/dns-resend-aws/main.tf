terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
}

locals {
  # Tags of DMARC record - see https://en.wikipedia.org/wiki/DMARC
  v     = "v=DMARC1;"
  pct   = var.dmarc.percentage != null ? "pct=${var.dmarc.percentage};" : ""
  ruf   = var.dmarc.forensic_report_email != null ? "ruf=mailto:${var.dmarc.forensic_report_email};" : ""
  rua   = var.dmarc.aggregate_report_email != null ? "rua=mailto:${var.dmarc.aggregate_report_email};" : ""
  p     = "p=${var.dmarc.policy};"
  sp    = var.dmarc.subdomain_policy != null ? "sp=${var.dmarc.subdomain_policy};" : ""
  adkim = var.dmarc.dkim_alignment_mode != null ? "adkim=${var.dmarc.dkim_alignment_mode};" : ""
  aspf  = var.dmarc.spf_alignment_mode != null ? "aspf=${var.dmarc.spf_alignment_mode};" : ""
  # Full DMARC record value
  dmarc = "${local.v}${local.pct}${local.ruf}${local.rua}${local.p}${local.sp}${local.adkim}${local.aspf}"
}

resource "aws_route53_record" "mx" {
  name    = "send.${var.root_domain}"
  zone_id = var.hosted_zone_id

  type    = "MX"
  ttl     = var.ttl
  records = [var.send_mx]
}

resource "aws_route53_record" "txt" {
  name    = "send.${var.root_domain}"
  zone_id = var.hosted_zone_id

  type    = "TXT"
  ttl     = var.ttl
  records = [var.send_txt]
}

resource "aws_route53_record" "domainkey" {
  name    = "resend._domainkey.${var.root_domain}"
  zone_id = var.hosted_zone_id

  type    = "TXT"
  ttl     = var.ttl
  records = [var.domainkey]
}

resource "aws_route53_record" "dmarc" {
  name    = "_dmarc.${var.root_domain}"
  zone_id = var.hosted_zone_id

  type    = "TXT"
  ttl     = var.ttl
  records = [local.dmarc]
}

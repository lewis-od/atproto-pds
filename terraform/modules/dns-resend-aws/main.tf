terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
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
  records = [var.dmarc]
}

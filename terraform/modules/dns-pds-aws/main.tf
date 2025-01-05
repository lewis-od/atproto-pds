terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
}

resource "aws_route53_record" "pds" {
  name    = "${var.pds_subdomain}.${var.hosted_zone_name}"
  zone_id = var.hosted_zone_id

  type    = "A"
  ttl     = var.ttl
  records = [var.pds_ip_address]
}

resource "aws_route53_record" "pds_star" {
  name    = "*.${aws_route53_record.pds.fqdn}"
  zone_id = var.hosted_zone_id

  type    = "A"
  ttl     = var.ttl
  records = [var.pds_ip_address]
}

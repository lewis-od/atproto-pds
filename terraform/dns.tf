data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

module "pds_dns" {
  source = "./modules/dns-pds-aws"

  hosted_zone_id   = data.aws_route53_zone.zone.id
  hosted_zone_name = data.aws_route53_zone.zone.name
  pds_ip_address   = module.pds_droplet.ip_address
}

moved {
  from = aws_route53_record.pds
  to   = module.pds_dns.aws_route53_record.pds
}

moved {
  from = aws_route53_record.pds_star
  to   = module.pds_dns.aws_route53_record.pds_star
}

resource "aws_route53_record" "resend_mx" {
  name    = "send.${module.pds_dns.pds_fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "MX"
  ttl     = "300"
  records = [var.resend_mx_record]
}

resource "aws_route53_record" "resend_txt" {
  name    = "send.${module.pds_dns.pds_fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "TXT"
  ttl     = "300"
  records = [var.resend_txt_record]
}

resource "aws_route53_record" "resend_domainkey" {
  name    = "resend._domainkey.${module.pds_dns.pds_fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "TXT"
  ttl     = "300"
  records = [var.resend_domainkey]
}

resource "aws_route53_record" "resend_dmarc" {
  name    = "_dmarc.${data.aws_route53_zone.zone.name}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=none;"]
}

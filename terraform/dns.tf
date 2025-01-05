data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "pds" {
  name    = "pds.${data.aws_route53_zone.zone.name}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "A"
  ttl     = "300"
  records = [module.pds_droplet.ip_address]
}

resource "aws_route53_record" "pds_star" {
  name    = "*.${aws_route53_record.pds.fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "A"
  ttl     = "300"
  records = [module.pds_droplet.ip_address]
}

resource "aws_route53_record" "resend_mx" {
  name    = "send.${aws_route53_record.pds.fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "MX"
  ttl     = "300"
  records = [var.resend_mx_record]
}

resource "aws_route53_record" "resend_txt" {
  name    = "send.${aws_route53_record.pds.fqdn}"
  zone_id = data.aws_route53_zone.zone.zone_id

  type    = "TXT"
  ttl     = "300"
  records = [var.resend_txt_record]
}

resource "aws_route53_record" "resend_domainkey" {
  name    = "resend._domainkey.${aws_route53_record.pds.fqdn}"
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

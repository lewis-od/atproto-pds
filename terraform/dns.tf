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

module "resend_dns" {
  source = "./modules/dns-resend-aws"

  root_domain    = module.pds_dns.pds_fqdn
  hosted_zone_id = data.aws_route53_zone.zone.id
  send_mx        = var.resend_mx_record
  send_txt       = var.resend_txt_record
  domainkey      = var.resend_domainkey
  dmarc = {
    policy           = "quarantine"
    subdomain_policy = "reject"
  }
}

moved {
  from = aws_route53_record.resend_mx
  to   = module.resend_dns.aws_route53_record.mx
}

moved {
  from = aws_route53_record.resend_txt
  to   = module.resend_dns.aws_route53_record.txt
}

moved {
  from = aws_route53_record.resend_domainkey
  to   = module.resend_dns.aws_route53_record.domainkey
}

moved {
  from = aws_route53_record.resend_dmarc
  to   = module.resend_dns.aws_route53_record.dmarc
}

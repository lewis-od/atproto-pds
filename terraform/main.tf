data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

module "pds_droplet" {
  source = "./modules/droplet"

  name        = "atproto-pds"
  region      = var.droplet_region
  ssh_key_ids = [var.digitalocean_ssh_key_id]
  firewall_rules_inbound = [
    {
      protocol         = "tcp",
      port_range       = "22",
      source_addresses = ["0.0.0.0/0", "::/0"],
    },
    {
      protocol         = "tcp",
      port_range       = "443",
      source_addresses = ["0.0.0.0/0", "::/0"],
    },
    {
      protocol         = "tcp",
      port_range       = "80",
      source_addresses = ["0.0.0.0/0", "::/0"],
    },
  ]
  firewall_rules_outbound = [
    {
      protocol              = "tcp",
      port_range            = "1-65535",
      destination_addresses = ["0.0.0.0/0", "::/0"],
    },
    {
      protocol              = "udp",
      port_range            = "1-65535",
      destination_addresses = ["0.0.0.0/0", "::/0"],
    },
  ]
}

module "pds_dns" {
  source = "./modules/dns-pds-aws"

  hosted_zone_id   = data.aws_route53_zone.zone.id
  hosted_zone_name = data.aws_route53_zone.zone.name
  pds_ip_address   = module.pds_droplet.ip_address
}

module "dmarc" {
  source = "./modules/dmarc"

  policy           = "quarantine"
  subdomain_policy = "reject"
}

module "resend_dns" {
  source = "./modules/dns-resend-aws"

  root_domain    = module.pds_dns.pds_fqdn
  hosted_zone_id = data.aws_route53_zone.zone.id
  send_mx        = var.resend_mx_record
  send_txt       = var.resend_txt_record
  domainkey      = var.resend_domainkey
  dmarc          = module.dmarc.dmarc_record
}

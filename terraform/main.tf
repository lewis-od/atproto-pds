data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

# TODO: remove this module, its variables and the digitalocean provider once the migration to OVH
# described in docs/migration-do-to-ovh.md is complete and the Droplet has been decommissioned
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

module "pds_instance" {
  source = "./modules/instance-ovh"

  name           = "atproto-pds"
  flavor_name    = var.ovh_flavor_name
  ssh_public_key = var.ssh_public_key
  firewall_rules_inbound = [
    {
      protocol         = "tcp",
      port             = 22,
      source_addresses = ["0.0.0.0/0"],
    },
    {
      protocol         = "tcp",
      port             = 443,
      source_addresses = ["0.0.0.0/0"],
    },
    {
      protocol         = "tcp",
      port             = 80,
      source_addresses = ["0.0.0.0/0"],
    },
  ]
}

module "pds_backup_storage" {
  source = "./modules/backup-storage-ovh"

  service_name = var.ovh_project_id
  region       = var.ovh_storage_region
  bucket_name  = var.backup_bucket_name
}

module "pds_dns" {
  source = "./modules/dns-pds-aws"

  hosted_zone_id   = data.aws_route53_zone.zone.id
  hosted_zone_name = data.aws_route53_zone.zone.name
  pds_ip_address   = var.cutover_dns_to_ovh ? module.pds_instance.ip_address : module.pds_droplet.ip_address
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

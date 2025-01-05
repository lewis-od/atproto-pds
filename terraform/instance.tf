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

moved {
  from = digitalocean_droplet.pds
  to   = module.pds_droplet.digitalocean_droplet.this
}

moved {
  from = digitalocean_reserved_ip.pds
  to   = module.pds_droplet.digitalocean_reserved_ip.this
}

moved {
  from = digitalocean_firewall.pds
  to   = module.pds_droplet.digitalocean_firewall.this
}

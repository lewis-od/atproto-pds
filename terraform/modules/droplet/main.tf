terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.46"
    }
  }
}

resource "digitalocean_droplet" "this" {
  name   = var.name
  region = var.region

  image      = var.image
  size       = var.size
  ssh_keys   = var.ssh_key_ids
  backups    = true
  monitoring = true

  backup_policy {
    plan    = "weekly"
    weekday = var.backup_day
    hour    = 0
  }
}

resource "digitalocean_reserved_ip" "this" {
  region     = var.region
  droplet_id = digitalocean_droplet.this.id
}

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = [digitalocean_droplet.this.id]

  dynamic "inbound_rule" {
    for_each = var.firewall_rules_inbound
    content {
      protocol         = inbound_rule.value["protocol"]
      port_range       = inbound_rule.value["port_range"]
      source_addresses = inbound_rule.value["source_addresses"]
    }
  }

  dynamic "outbound_rule" {
    for_each = var.firewall_rules_outbound
    content {
      protocol              = outbound_rule.value["protocol"]
      port_range            = outbound_rule.value["port_range"]
      destination_addresses = outbound_rule.value["destination_addresses"]
    }
  }
}

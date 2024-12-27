resource "digitalocean_droplet" "pds" {
  name   = "atproto-pds"
  region = "lon1"

  image      = "ubuntu-22-04-x64"
  size       = "s-1vcpu-1gb"
  ssh_keys   = [var.digitalocean_ssh_key_id]
  backups    = true
  monitoring = true

  backup_policy {
    plan    = "weekly"
    weekday = "SUN"
    hour    = 0
  }
}

resource "digitalocean_reserved_ip" "pds" {
  region     = "lon1"
  droplet_id = digitalocean_droplet.pds.id
}

resource "digitalocean_firewall" "pds" {
  name = "atproto-pds"

  droplet_ids = [digitalocean_droplet.pds.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

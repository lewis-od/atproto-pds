resource "digitalocean_droplet" "pds" {
  name   = "atproto-pds"
  region = "lon1"

  image      = "ubuntu-22-04-x64"
  size       = "s-1vcpu-1gb"
  ssh_keys   = [var.digitalocean_ssh_key_id]
  backups    = true
  monitoring = true
  user_data  = file("./scripts/userdata.sh")

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

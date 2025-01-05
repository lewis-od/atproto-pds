output "ip_address" {
  value       = digitalocean_reserved_ip.this.ip_address
  description = "Reserved IP address of the Droplet"
}

output "server_ip" {
  value = digitalocean_reserved_ip.pds.ip_address
}

output "ip_address" {
  value       = openstack_compute_instance_v2.this.access_ip_v4
  description = "Public IPv4 address of the instance"
}

output "instance_id" {
  value       = openstack_compute_instance_v2.this.id
  description = "OpenStack ID of the instance"
}

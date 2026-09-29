# instance-ovh

Creates an OVH Public Cloud instance with a public IP and the specified inbound firewall rules

Uses the OpenStack provider rather than the OVH provider, because security groups are an OpenStack
(Neutron) concept that the OVH API does not expose. OVH Public Cloud runs on OpenStack, so both
providers act on the same project — the OpenStack tenant ID is the OVH public cloud project ID.

Egress is unrestricted. Ingress is denied by default once the security group is attached, which
matches the behaviour of a DigitalOcean firewall. Note that an OVH instance with no security group
of its own falls back to the permissive `default` group, so this module is what closes the box.

## Resources

- https://docs.ovhcloud.com/en/guides/public-cloud/cross-functional/security-group-private-network
- https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs

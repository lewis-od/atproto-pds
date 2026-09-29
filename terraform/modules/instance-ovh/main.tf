terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
  }
}

data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "this" {
  name = var.flavor_name
}

resource "openstack_compute_keypair_v2" "this" {
  name       = var.name
  public_key = var.ssh_public_key
}

locals {
  # OpenStack rules take a single CIDR each, so expand the per-port source lists
  inbound_rules = merge([
    for rule in var.firewall_rules_inbound : {
      for source in rule.source_addresses :
      "${rule.protocol}-${rule.port}-${source}" => {
        protocol = rule.protocol
        port     = rule.port
        source   = source
      }
    }
  ]...)
}

resource "openstack_networking_secgroup_v2" "this" {
  name        = var.name
  description = "Ingress rules for ${var.name}"

  # The implicit allow-all egress rules match the outbound rules we had on DigitalOcean
  delete_default_rules = false
}

resource "openstack_networking_secgroup_rule_v2" "inbound" {
  for_each = local.inbound_rules

  security_group_id = openstack_networking_secgroup_v2.this.id
  direction         = "ingress"
  ethertype         = strcontains(each.value.source, ":") ? "IPv6" : "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.source
}

resource "openstack_compute_instance_v2" "this" {
  name            = var.name
  image_id        = data.openstack_images_image_v2.this.id
  flavor_id       = data.openstack_compute_flavor_v2.this.id
  key_pair        = openstack_compute_keypair_v2.this.name
  security_groups = [openstack_networking_secgroup_v2.this.name]

  network {
    name = var.public_network_name
  }
}

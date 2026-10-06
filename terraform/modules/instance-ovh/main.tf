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
  # OpenStack rules took a single CIDR each; nftables does too, so keep the per-port expansion
  inbound_rules = flatten([
    for rule in var.firewall_rules_inbound : [
      for source in rule.source_addresses : {
        protocol = rule.protocol
        port     = rule.port
        source   = source
        family   = strcontains(source, ":") ? "ip6" : "ip"
      }
    ]
  ])

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    nftables_conf = templatefile("${path.module}/templates/nftables.conf.tftpl", {
      rules = local.inbound_rules
    })
  })
}

resource "openstack_compute_instance_v2" "this" {
  name      = var.name
  image_id  = data.openstack_images_image_v2.this.id
  flavor_id = data.openstack_compute_flavor_v2.this.id
  key_pair  = openstack_compute_keypair_v2.this.name

  # The OVH project has no security group quota, so filtering happens on the instance instead
  user_data = local.user_data

  network {
    name = var.public_network_name
  }
}

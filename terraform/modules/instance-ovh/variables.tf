variable "name" {
  type        = string
  description = "Name of the instance, keypair and security group"
}

variable "flavor_name" {
  type        = string
  description = "Instance flavor. For the list of available flavors, see https://www.ovhcloud.com/en-gb/public-cloud/prices/"
  default     = "d2-2"
}

variable "image_name" {
  type        = string
  description = "Name of the OpenStack image to boot from, as shown in the OVH control panel"
  default     = "Ubuntu 22.04"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to install on the instance"
}

variable "public_network_name" {
  type        = string
  description = "Name of the OVH public network to attach the instance to"
  default     = "Ext-Net"
}

variable "firewall_rules_inbound" {
  type = list(object({
    protocol         = string,
    port             = number,
    source_addresses = list(string),
  }))
  description = "Inbound firewall rules for the instance. Egress is unrestricted."
  default     = []
}

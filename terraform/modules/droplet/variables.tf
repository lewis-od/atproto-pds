variable "name" {
  type        = string
  description = "Name of the Droplet and associated firewall"
}

variable "region" {
  type        = string
  description = "Region to create the Droplet in"
}

variable "image" {
  type        = string
  description = "From the list of available images at https://docs.digitalocean.com/products/droplets/details/images/"
  default     = "ubuntu-22-04-x64"
}

variable "size" {
  type        = string
  description = "For the list of available sizes, call the endpoint described at https://docs.digitalocean.com/reference/api/api-reference/#operation/sizes_list"
  default     = "s-1vcpu-1gb"
}

variable "ssh_key_ids" {
  type        = list(string)
  description = "IDs of the Digital Ocean SSH keys to be added to the Droplet. Can be retrieved from https://api.digitalocean.com/v2/account/keys"
  default     = []
}

variable "backup_time" {
  type        = number
  description = "Hour of the day that the 4 hour backup windows starts."
  default     = 0

  validation {
    condition     = contains([0, 4, 8, 12, 16, 20], var.backup_time)
    error_message = "Must be one of: 0, 4, 8, 12, 16, 20"
  }
}

variable "firewall_rules_inbound" {
  type = list(object({
    protocol         = string,
    port_range       = string,
    source_addresses = list(string),
  }))
  description = "Inbound firewall rules for the droplet"
  default     = []
}

variable "firewall_rules_outbound" {
  type = list(object({
    protocol              = string,
    port_range            = string,
    destination_addresses = list(string),
  }))
  description = "Outbound firewall rules for the droplet"
  default     = []
}

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
  default     = "ubuntu-22-04-x64"
  description = "From the list of available images at https://docs.digitalocean.com/products/droplets/details/images/"
}

variable "size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "For the list of available sizes, call the endpoint described at https://docs.digitalocean.com/reference/api/api-reference/#operation/sizes_list"
}

variable "ssh_key_ids" {
  type        = list(string)
  default     = []
  description = "IDs of the Digital Ocean SSH keys to be added to the Droplet. Can be retrieved from https://api.digitalocean.com/v2/account/keys"
}

variable "backup_day" {
  type        = string
  default     = "SUN"
  description = "Day of the week to perform the weekly backup"

  validation {
    condition     = contains(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], var.backup_day)
    error_message = "Must be a day of the week (e.g. MON)"
  }
}

variable "firewall_rules_inbound" {
  type = list(object({
    protocol         = string,
    port_range       = string,
    source_addresses = list(string),
  }))
  default     = []
  description = "Inbound firewall rules for the droplet"
}

variable "firewall_rules_outbound" {
  type = list(object({
    protocol              = string,
    port_range            = string,
    destination_addresses = list(string),
  }))
  default     = []
  description = "Outbound firewall rules for the droplet"
}

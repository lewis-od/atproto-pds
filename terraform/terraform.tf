terraform {
  required_version = "~> 1.10.3"

  required_providers {
    # TODO: remove once the DigitalOcean Droplet has been decommissioned
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.46.1"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.1.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = "2.21.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }

  backend "s3" {}
}

# TODO: remove once the DigitalOcean Droplet has been decommissioned
provider "digitalocean" {
  token = var.digitalocean_token
}

# OVH Public Cloud runs on OpenStack, and the OpenStack tenant is the OVH public cloud project
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"
  tenant_id   = var.ovh_project_id
  user_name   = var.openstack_user_name
  password    = var.openstack_password
  region      = var.ovh_compute_region
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

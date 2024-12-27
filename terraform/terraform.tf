terraform {
  required_version = "1.10.3"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.46.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

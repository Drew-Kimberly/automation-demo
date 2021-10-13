terraform {
  required_version = ">=1.0.0, < 1.1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.80.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_access_token
}

provider "azurerm" {
  features {}
}

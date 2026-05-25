terraform {
  required_version = ">= 1.0.0"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  user_name = var.user_name
  tenant_name = var.tenant_name
  password = var.password
  auth_url = var.auth_url
  region = var.region
}

provider "openstack" {
  alias       = "services"
  user_name   = "octavia"
  password    = "octavia"
  tenant_name = "services"
  auth_url    = var.auth_url
  region      = var.region
}
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# 1. infra의 결과물 참조
data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "${path.module}/../infra/terraform.tfstate"
  }
}

# 2. 모듈 호출 및 값 전달
module "web_lb" {
  source = "../modules/loadbalancer"

  lb_name           = "web-lb"
  vip_subnet_id     = data.terraform_remote_state.infra.outputs.subnet_1_id
  backend_subnet_id = data.terraform_remote_state.infra.outputs.subnet_2_id
  backend_address   = data.terraform_remote_state.infra.outputs.instance_2_ip
  external_net_name = data.terraform_remote_state.infra.outputs.external_net_name
}
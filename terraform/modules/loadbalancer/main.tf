terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

resource "openstack_lb_loadbalancer_v2" "web_lb" {
  name           = var.lb_name
  vip_subnet_id  = var.vip_subnet_id
}

resource "openstack_lb_listener_v2" "web_listener" {
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.web_lb.id
}

resource "openstack_lb_pool_v2" "web_pool" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.web_listener.id
}

resource "openstack_lb_member_v2" "backend_member" {
  pool_id       = openstack_lb_pool_v2.web_pool.id
  subnet_id     = var.backend_subnet_id
  address       = var.backend_address
  protocol_port = 80
}

# Floating IP 생성
resource "openstack_networking_floatingip_v2" "lb_fip" {
  pool = var.external_net_name
}

# 로드밸런서 VIP와 Floating IP 연결
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.lb_fip.address
  port_id = openstack_lb_loadbalancer_v2.web_lb.vip_port_id
}
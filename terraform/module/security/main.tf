terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
      configuration_aliases = [ openstack.services ]
    }
  }
}

resource "openstack_networking_secgroup_v2" "public_sg" { name = "public-sg" }
resource "openstack_networking_secgroup_v2" "private_sg" { name = "private-sg" }

# Bastion SSH/HTTP 허용
resource "openstack_networking_secgroup_rule_v2" "bastion_ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.public_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_http" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.public_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.public_sg.id
}

# Private은 Bastion 대역(172.16.111.0/24)에서 오는 것만 허용
resource "openstack_networking_secgroup_rule_v2" "private_ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "172.16.111.0/24"
  security_group_id = openstack_networking_secgroup_v2.private_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "private_http" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "172.16.111.0/24"
  security_group_id = openstack_networking_secgroup_v2.private_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "private_icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "172.16.111.0/24"
  security_group_id = openstack_networking_secgroup_v2.private_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "private_own" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "172.16.222.0/24"
  security_group_id = openstack_networking_secgroup_v2.private_sg.id
}

resource "openstack_networking_secgroup_v2" "lb_mgmt_sg" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  name = "lb-mgmt-sec-grp"
}

# 5555(API), 10514(UDP Health), 9443 포트 허용
resource "openstack_networking_secgroup_rule_v2" "lb_mgmt_rules" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  for_each = {
    api = { port = 5555, proto = "tcp" }
    health = { port = 10514, proto = "udp" }
    mgmt = { port = 9443, proto = "tcp" }
  }

  direction = "ingress"
  ethertype = "IPv4"
  protocol = each.value.proto
  port_range_min = each.value.port
  port_range_max = each.value.port
  security_group_id = openstack_networking_secgroup_v2.lb_mgmt_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_mgmt_icmp" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.lb_mgmt_sg.id
}

# VRRP 통신을 위한 1550 포트 허용 (HA 구성 및 상태 체크용)
resource "openstack_networking_secgroup_rule_v2" "lb_mgmt_vrrp" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1550
  port_range_max    = 1550
  security_group_id = openstack_networking_secgroup_v2.lb_mgmt_sg.id
}
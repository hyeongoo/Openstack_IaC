terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Flavor 정의
resource "openstack_compute_flavor_v2" "m1_custom" {
  name = "m1.custom"
  ram = 1024
  vcpus = 1
  disk = 10
}

# [인스턴스 1] Bastion / Proxy 서버
resource "openstack_compute_instance_v2" "instance_1" {
  name = "instance1"
  image_name = "Ubuntu-24.04-Latest"
  flavor_id = openstack_compute_flavor_v2.m1_custom.id
  key_pair = "mykey1"
  security_groups = [var.public_sg_name]

  network {
    uuid = var.network_1_id
  }
}

# [인스턴스 2] Backend 서버
resource "openstack_compute_instance_v2" "instance_2" {
  name = "instance2"
  image_name = "Ubuntu-24.04-Latest"
  flavor_name = "m1.small"
  key_pair = "mykey2"
  security_groups = [var.private_sg_name]

  network {
    uuid = var.network_2_id
  }

}

# Floating IP 및 연결
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = var.external_net_name
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.instance_1.id
}

resource "openstack_compute_flavor_v2" "amphora_flavor" {
  name = "m1.amphora"
  ram = 1024
  vcpus = 1
  disk = 5
}
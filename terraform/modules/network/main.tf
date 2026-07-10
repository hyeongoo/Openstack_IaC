terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
      configuration_aliases = [ openstack.services ]
    }
  }
}

data "openstack_networking_network_v2" "external_net" {
  name = "public_network"
  external = true
}

resource "openstack_networking_network_v2" "network_1" { name = "network1" }
resource "openstack_networking_subnet_v2" "subnet_1" {
  name = "subnet1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr = var.subnet_1_cidr
  ip_version = 4
}

resource "openstack_networking_network_v2" "network_2" { name = "network2" }
resource "openstack_networking_subnet_v2" "subnet_2" {
  name = "subnet2"
  network_id = openstack_networking_network_v2.network_2.id
  cidr = var.subnet_2_cidr
  ip_version = 4
}

resource "openstack_networking_router_v2" "router_1" {
  name = "router1"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

resource "openstack_networking_router_interface_v2" "int_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_router_interface_v2" "int_2" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_2.id
}


# LB 관리 네트워크 및 서브넷
resource "openstack_networking_network_v2" "lb_mgmt_net" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  name = "lb-mgmt-net"
}

resource "openstack_networking_subnet_v2" "lb_mgmt_subnet" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  name = "lb-mgmt-subnet"
  network_id = openstack_networking_network_v2.lb_mgmt_net.id
  cidr = "192.168.100.0/24"
  ip_version = 4
}

# o-hm0로 사용될 포트 생성 (IP 고정)
resource "openstack_networking_port_v2" "octavia_hm_port" {
  tenant_id = "ffe693c0ea2c416895720db49aabbf66"
  name = "octavia-health-manager-port"
  network_id = openstack_networking_network_v2.lb_mgmt_net.id
  device_owner = "network:secondary_body"
  admin_state_up = "true"

  fixed_ip {
    ip_address = "192.168.100.5"
    subnet_id  = openstack_networking_subnet_v2.lb_mgmt_subnet.id
  }

  # 생성된 MAC 주소를 rc.local에 자동으로 주입
  provisioner "local-exec" {
    command = <<EOT
# 1. 기존 o-hm0 관련 설정 및 모든 exit 0 삭제 (중복 및 꼬임 방지)
sed -i '/o-hm0/d' /etc/rc.d/rc.local
sed -i '/exit 0/d' /etc/rc.d/rc.local

# 2. 파일 끝에 빈 줄을 하나 추가하여 기존 내용과 구분 (선택 사항)
echo "" >> /etc/rc.d/rc.local

# 3. o-hm0 설정값 추가
cat <<EOF >> /etc/rc.d/rc.local
ovs-vsctl --may-exist add-port br-int o-hm0 -- set Interface o-hm0 type=internal other_config:hwaddr=${self.mac_address}
ip addr flush dev o-hm0
ip addr add 192.168.100.5/24 dev o-hm0
ip link set o-hm0 up
ip route replace 192.168.100.0/24 dev o-hm0
EOF

# 4. 파일의 맨 마지막 줄에 exit 0을 딱 한 번만 추가
echo "exit 0" >> /etc/rc.d/rc.local

# 5. 권한 부여 및 즉시 실행
chmod +x /etc/rc.d/rc.local
/etc/rc.d/rc.local
EOT
  }
}
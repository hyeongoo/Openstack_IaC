# 인스턴스 1의 Floating IP
output "instance_1_ip" { value = openstack_networking_floatingip_v2.fip_1.address }

# 인스턴스 2의 내부 IP (앤서블의 backend_address로 사용)
output "instance_2_ip" { value = openstack_compute_instance_v2.instance_2.network.0.fixed_ip_v4 }

# Amphora용 플레이버 ID (앤서블의 amp_flavor_id로 사용)
output "amphora_flavor_id" { value = openstack_compute_flavor_v2.amphora_flavor.id }
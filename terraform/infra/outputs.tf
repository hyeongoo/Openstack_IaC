output "net_id" {
  value = module.network.network_1_id
}

output "subnet_1_id" {
  value = module.network.subnet_1_id
}

output "subnet_2_id" {
  value = module.network.subnet_2_id
}

output "sg_id" {
  value = module.security.lb_mgmt_sg_id
}

output "instance_2_ip" {
  # 인스턴스 2의 고정 IP 주소 (로드밸런서의 멤버로 등록될 주소)
  value = module.compute.instance_2_ip
}

output "amphora_flavor_id" {
  value = module.compute.amphora_flavor_id
}
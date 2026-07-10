# 1. 네트워크 모듈 호출
module "network" {
  source = "../modules/network"
  providers = {
    openstack = openstack
    openstack.services = openstack.services
  }
}

# 2. 보안 그룹 모듈 호출
module "security" {
  source = "../modules/security"
  providers = {
    openstack = openstack
    openstack.services = openstack.services
  }
}

# 3. 컴퓨트 모듈 호출 (인스턴스 생성)
module "compute" {
  source = "../modules/compute"

  # network/security 모듈의 output을 전달
  network_1_id      = module.network.network_1_id
  network_2_id      = module.network.network_2_id
  router_int_2_id   = module.network.router_int_2_id
  external_net_name = module.network.external_net_name
  public_sg_name    = module.security.public_sg_name
  private_sg_name   = module.security.private_sg_name

  # 명시적 의존성
  depends_on = [
    module.network,
    module.security
  ]
}
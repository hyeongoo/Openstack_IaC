output "lb_vip" { value = openstack_lb_loadbalancer_v2.web_lb.vip_address }

output "lb_floating_ip" { value = openstack_networking_floatingip_v2.lb_fip.address }
output "public_sg_name" { value = openstack_networking_secgroup_v2.public_sg.name }
output "private_sg_name" { value = openstack_networking_secgroup_v2.private_sg.name }
output "lb_mgmt_sg_id" { value = openstack_networking_secgroup_v2.lb_mgmt_sg.id }
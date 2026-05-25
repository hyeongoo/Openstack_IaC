resource "local_file" "ansible_vars" {
  content = <<-EOT
terraform_out_flavor_id: "${module.compute.amphora_flavor_id}"
terraform_out_net_id: "${module.network.lb_mgmt_net_id}"
terraform_out_sg_id: "${module.security.lb_mgmt_sg_id}"
terraform_out_mac: "${module.network.hm_port_mac}"
proxy_fip: "${module.compute.instance_1_ip}"
instance_2_ip: "${module.compute.instance_2_ip}"
  EOT
  filename = "${path.module}/../../ansible/tf_vars.yml"
}

resource "local_file" "hosts_ini" {
  content  = <<-EOT
[proxy]
instance1 ansible_host=${module.compute.instance_1_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/root/mykey1.pem

[backend]
instance2 ansible_host=${module.compute.instance_2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/root/mykey2.pem

[backend:vars]
ansible_ssh_common_args="-o ProxyCommand='ssh -i /root/mykey1.pem -W %h:%p -q ubuntu@${module.compute.instance_1_ip} -o StrictHostKeyChecking=no' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  EOT
  filename = "${path.module}/../../ansible/hosts.ini"
}
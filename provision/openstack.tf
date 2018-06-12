provider "openstack" {
 user_name             = "${var.user_name}"
 project_domain_name   = "${var.project_name}"
 password              = "${var.password}"
 auth_url              = "https://stack.intra.codilime.com:5000/v3"
 region                = "${var.region}"
 user_domain_name      = "${var.domain_name}"
 tenant_id             = "${var.project_id}"
}

resource "openstack_compute_keypair_v2" "KeyPair"{
 name                   = "${replace(var.user_name,".","-")}-KeyPair"
 public_key             = "${file("${var.ssh_key_file}")}"
 region                 = "${var.region}"
}

resource "openstack_networking_network_v2" "contrail_net" {
 name                   = "${var.user_name}-contrail_net"
 admin_state_up         = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
 name                   = "${var.user_name}-subnet_1"
 network_id             = "${openstack_networking_network_v2.contrail_net.id}"
 cidr                   = "192.168.1.0/24"
 ip_version             = 4
}

resource "openstack_networking_router_v2" "contrail_router_1" {
 name                   = "${var.user_name}-contrail_router_1"
 admin_state_up         = "true"
 external_network_id    = "d5ae8d1d-c1fe-4f11-8a9d-4137e4ac0eab"
}

resource "openstack_networking_router_interface_v2" "int_1" {
 router_id              = "${openstack_networking_router_v2.contrail_router_1.id}"
 subnet_id              = "${openstack_networking_subnet_v2.subnet_1.id}"
}

resource "openstack_compute_secgroup_v2" "contrail_security_group" {
 name                   = "${var.user_name}-contrail_security_group"
 description            = "Security Group for contrail_net"
 
 rule {
    from_port           = 22
    to_port             = 22
    ip_protocol         = "tcp"
    cidr                = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "basic" {
  name                  = "${var.user_name}"
  image_id              = "d1ccf955-b11a-4a68-b578-8255367f7f9b"
  flavor_name           = "m2.mini"
  key_pair              = "${openstack_compute_keypair_v2.KeyPair.id}"
  security_groups       = ["${openstack_compute_secgroup_v2.contrail_security_group.id}"]
  region                = "${var.region}"
  
network {
 uuid                    = "${openstack_networking_network_v2.contrail_net.id}"
  }

  
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
 pool                   = "public"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_1" {
 floating_ip            = "${openstack_networking_floatingip_v2.floatip_1.address}"
 instance_id            = "${openstack_compute_instance_v2.basic.id}"
 region                 = "${var.region}"

 provisioner "remote-exec"{
   connection {
   type = "ssh"
   user = "centos"
   password =""
   agent = "false"
   host = "${openstack_networking_floatingip_v2.floatip_1.address}"
   private_key = "${file(var.ssh_private_key)}"
   } 

   inline = [
     "touch /tmp/testfile"
   ]
  }
  
}

output "IP Address of new instance:" {
 value                  = "${openstack_networking_floatingip_v2.floatip_1.address}"
}

output "instance ID" {
 value                  = "${openstack_compute_instance_v2.basic.id}"

}



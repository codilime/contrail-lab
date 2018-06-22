provider "openstack" {
 user_name              = "${var.user_name}"
 project_domain_name    = "${var.project_name}"
 password               = "${var.password}"
 auth_url               = "https://stack.intra.codilime.com:5000/v3"
 user_domain_name       = "${var.domain_name}"
 tenant_id              = "${var.project_id}"
}

resource "openstack_compute_keypair_v2" "KeyPair"{
 name                   = "${replace(var.user_name,".","-")}-KeyPair"
 public_key             = "${file("${var.ssh_key_file}")}"
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

rule {
    from_port           = 8143
    to_port             = 8143
    ip_protocol         = "tcp"
    cidr                = "0.0.0.0/0"
  }

rule {
    from_port           = 80
    to_port             = 80
    ip_protocol         = "tcp"
    cidr                = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "basic" {
  name                  = "${var.user_name}"
  image_id              = "d1ccf955-b11a-4a68-b578-8255367f7f9b"
  flavor_name           = "m2.large"
  key_pair              = "${openstack_compute_keypair_v2.KeyPair.id}"
  security_groups       = ["${openstack_compute_secgroup_v2.contrail_security_group.id}"]
  
network {
   name					= "${var.network_name}"
  }

  
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
 pool                   = "public"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_1" {
 floating_ip            = "${openstack_networking_floatingip_v2.floatip_1.address}"
 instance_id            = "${openstack_compute_instance_v2.basic.id}"

 provisioner "remote-exec"{
   connection {
   type				    = "ssh"
   user					= "centos"
   password				= ""
   agent				= "false"
   host					= "${openstack_networking_floatingip_v2.floatip_1.address}"
   private_key			= "${file(var.ssh_private_key)}"
   timeout				= "3m"
   } 

   inline = [
    "sudo yum -y update kernel",
    "sudo yum -y install kernel-devel kernel-headers",
    "sudo grub2-set-default 0",
    "sudo mkdir /etc/docker",
   ]
}



provisioner "file"{
 source					= "daemon.json"
 destination			= "/tmp/daemon.json"

connection {
 type					= "ssh"
 agent					= "false"
 user					= "centos"
 host					= "${openstack_networking_floatingip_v2.floatip_1.address}"
 private_key			= "${file(var.ssh_private_key)}"

}
}

provisioner "remote-exec"{
 connection {
 type					= "ssh"
 user					= "centos"
 password				= ""
 agent					= "false"
 host					= "${openstack_networking_floatingip_v2.floatip_1.address}"
 private_key			= "${file(var.ssh_private_key)}"
 timeout				= "3m"

 }

inline = [
"sudo cp /tmp/daemon.json /etc/docker/",
]

}
}

output "ip" {
 value                  = "${openstack_networking_floatingip_v2.floatip_1.address}"
}

output "instance ID" {
 value                  = "${openstack_compute_instance_v2.basic.id}"

}



provider "openstack" {
  user_name           = "${var.user_name}"
  project_domain_name = "${var.domain_name}"
  password            = "${var.password}"
  auth_url            = "https://stack.intra.codilime.com:5000/v3"
  user_domain_name    = "${var.domain_name}"
  tenant_id           = "${var.project_id}"
}

resource "openstack_compute_keypair_v2" "KeyPair" {
  name       = "${replace(var.user_name,".","-")}-${var.machine_name}-KeyPair"
  public_key = "${file("${var.ssh_key_file}")}"

}

resource "openstack_compute_secgroup_v2" "contrail_security_group" {
  name        = "${var.user_name}-${var.machine_name}-contrail_security_group"
  description = "Security Group for contrail_net"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 1024
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_blockstorage_volume_v2" "volume" {
  name = "${var.user_name}-${var.machine_name}-volume"
  size = 100
}

resource "openstack_compute_instance_v2" "basic" {
  name            = "${var.user_name}-${var.machine_name}"
  image_id        = "7977cc5c-3fa0-4f30-a834-d1a7353f4ac1"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.KeyPair.id}"
  security_groups = ["${openstack_compute_secgroup_v2.contrail_security_group.id}"]

  network {
    name = "${var.network_name}"
  }
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "public"
}

locals {
  contrail_path = "$HOME/go/src/github.com/Juniper/contrail"
  checkout_patchset = "${var.patchset_ref != "master" ? "git init && git fetch https://review.opencontrail.org/Juniper/contrail ${var.patchset_ref} && git checkout FETCH_HEAD" : "echo \"default_branch: master\""}"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
  instance_id = "${openstack_compute_instance_v2.basic.id}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "5m"
    }

    inline = [
      "sudo easy_install pip==18.1",
      "sudo yum remove -y --tolerant python2-pip python-yaml python-requests",
      "sudo yum install -y epel-release",
      "sudo yum update -y",
      "sudo yum install -y git tcpdump tree vim nmap wget lnav htop",
      "sudo pip install ansible==2.4.2 PyYAML requests==2.11.1",
    ]
  }

  provisioner "file" {
    source      = "/${var.path}/daemon.json"
    destination = "/tmp/daemon.json"

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "centos"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "3m"
    }

    inline = [
      "sudo mkdir -p /etc/docker",
      "sudo cp /tmp/daemon.json /etc/docker/",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "5m"
    }

    inline = [
      "git clone http://github.com/Juniper/contrail-ansible-deployer -b ${var.branch}",
      "git clone https://github.com/Juniper/contrail ${local.contrail_path}",
      "cd ${local.contrail_path}",
      "${local.checkout_patchset}",
    ]
  }

  provisioner "local-exec" {
    command = "${var.path}/prepare_template ${openstack_compute_instance_v2.basic.network.0.fixed_ip_v4} ${var.routerip} ${var.path}"
  }

  provisioner "file" {
    source      = "${var.ssh_private_key}"
    destination = "/tmp/id_rsa"

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "centos"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "file" {
    source      = "${var.path}/instances.yaml"
    destination = "/tmp/instances.yaml"

    connection {
      type        = "ssh"
      agent       = "false"
      user        = "centos"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "5m"
    }

    inline = [
      "cd /home/centos",
      "sudo cp /tmp/instances.yaml /home/centos/contrail-ansible-deployer/config/",
      "sudo cp /tmp/id_rsa /home/centos/",
      "sudo chmod +x /usr/local/bin/vrouter.sh",
      "sudo chmod 600 /home/centos/id_rsa",
      "cd contrail-ansible-deployer",
      "sudo ansible-playbook -e orchestrator=openstack -i inventory/ playbooks/configure_instances.yml",
      "sudo ansible-playbook -i inventory playbooks/install_openstack.yml -v",
      "sudo ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/install_contrail.yml",
      "echo ${openstack_compute_instance_v2.basic.network.0.fixed_ip_v4} $HOSTNAME | sudo tee --append /etc/hosts",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "5m"
    }

    inline = [
      "cd ${local.contrail_path}",
      "ansible-playbook -e contrail_type=${var.contrail_type} -e contrail_path=${local.contrail_path} playbooks/contrail-go/deploy.yaml",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      password    = ""
      agent       = "false"
      host        = "${openstack_networking_floatingip_v2.floatip_1.address}"
      private_key = "${file(var.ssh_private_key)}"
      timeout     = "5m"
    }

    inline = [
      "sudo usermod -aG docker centos",
      "sudo systemctl enable docker",
    ]
  }
}

output "ip" {
  value = "${openstack_networking_floatingip_v2.floatip_1.address}"
}

output "localip" {
  value = "${openstack_compute_instance_v2.basic.network.0.fixed_ip_v4}"
}

output "instance ID" {
  value = "${openstack_compute_instance_v2.basic.id}"
}
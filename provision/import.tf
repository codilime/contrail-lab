resource "openstack_networking_router_v2" "router" {
  name                = "${var.router_name}"
  admin_state_up      = true
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.network_name}"
  admin_state_up = "true"
}
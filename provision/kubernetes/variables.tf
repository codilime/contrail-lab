variable "user_name" {
  default = "@USERNAME"
}

variable "password" {
  default = "@PASSWORD"
}

variable "router_name" {
  default = "@ROUTER_NAME"
}

variable "project_id" {
  default = "@PROJECTID"
}

variable "network_name" {
  default = "@NETWROK_NAME"
}

variable "network_id" {
  default = "@NETWORK_ID"
}

variable "domain_name" {
  default = "@DOMAIN_NAME"
}

variable "project_name" {
  default = "@PROJECT_NAME"
}

variable "routerip" {
  default = "@ROUTERIP"
}

variable "branch" {
  default = "master"
}

#Don't touch this !
variable "ssh_key_file" {
  default = "./id_rsa.pub"
}

variable "ssh_private_key" {
  default = "./id_rsa"
}

variable "flavor" {
  default = "@FLAVOR"
}

variable "contrail_type" {
  default = "vnc_api"
}

variable "patchset_ref" {
  default = "master"
}

variable "machine_name" {
  default = "@MACHINE_NAME"
}

variable "main_directory_name" {
  default = "@MAIN_DIRECTORY_NAME"
}

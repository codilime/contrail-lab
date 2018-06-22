variable "user_name" {
  default = "@USERNAME"
}

variable "password" {
 default = "@PASSWORD"
}

variable "network_name" {
  default = "@NETWORK_NAME"
}

variable "router_name"{
    default ="@ROUTER_NAME"
}

variable "project_id" {
 default="@PROJECTID"
}

variable "domain_name" {
 default = "@DOMAIN_NAME"
}

variable "project_name" {
 default = "@PROJECT_NAME"
}

#Don't touch this ! 
variable "ssh_key_file" {
 default = "./id_rsa.pub"
}

variable "ssh_private_key" {  
 default = "./id_rsa"
}
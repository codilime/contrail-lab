variable "user_name" {
  default = ""
}

variable "password" {
 default = ""
}

variable "ssh_key_file" {
 #PATH to public ssh key   
 default = "C:\\Users\\pma\\terraform\\pub_key1"
}

variable "ssh_private_key" {
 #PATH to public ssh key   
 default = "C:\\Users\\pma\\private.txt"
}

variable "region" {
 default = "RegionOne"
}

variable "project_id" {
 default="91de03c6ceb849e8b64d7b3fcc794489"
}

variable "domain_name" {
 default = "Users"
}

variable "project_name" {
 default = "JUN-contrail-lab"
}
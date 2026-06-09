variable "name_prefix" {
  type    = string
  default = "eschool"
}

variable "location" {
  type    = string
  default = "denmarkeast"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_count" {
  type    = number
  default = 2
}
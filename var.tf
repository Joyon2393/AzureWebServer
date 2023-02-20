variable "packer_resource_group_name" {
  description = "Name of the resource group in which the Packer image is created"
  default     = "myPackerImage"
}

variable "packer_image_name" {
  description = "Name of the Packer image"
  default     = "dev-image"
}
variable "location" {
  default     = "eastus"
  description = "Location where resources will be created"
}
variable "resource_group_name" {
  description = "Name of the resource group in which the resource will be created"
  default     = "myResourceGroup"
}

variable "number_of_VM" {
  description = "minimum VM deployment"
  default = 2
  
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   
}

variable "admin_password" {
   description = "Default password for admin account"
}
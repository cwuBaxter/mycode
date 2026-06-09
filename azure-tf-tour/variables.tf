variable "resource_group_name" {
  type        = string
  description = "Name of the pre-existing resource group assigned to this student"
}

variable "vnet_name" {
  type    = string
  default = "myTFVnet"
}

variable "address_space" {
type = string


}

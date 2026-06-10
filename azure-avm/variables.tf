variable "resource_group_name" {
  type        = string
  description = "Name of the pre-existing resource group assigned to this student"
}

variable "address_space" {
  type        = string
  description = "CIDR range for the Virtual Network"
  default     = "10.0.0.0/16"
}


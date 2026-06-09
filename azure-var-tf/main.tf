# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type        = string
  description = "Name of the pre-existing resource group assigned to this student"
}

# The name variable controls the VNet name and has a default value
variable "name" {
  type        = string
  description = "Name for the virtual network"
  default     = "my-tf-vnet"
}

variable "address_space" {
  type        = string
  description = "CIDR range for the virtual network"
  default     = "10.0.0.0/16"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  address_space       = [var.address_space]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" {
address_prefixes 

}





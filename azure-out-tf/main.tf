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

variable "name" {
  type        = string
  description = "Name for the virtual network"
  default     = "my-tf-vnet"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Return the ID of the virtual network we just created
output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the virtual network"
}

# Return the ID of the resource group (read from data source)
output "rg_id" {
  value       = data.azurerm_resource_group.rg.id
  description = "ID of the resource group"
}


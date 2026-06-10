data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Deploy a virtual network using the Azure Verified Module
# Module docs: https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name                = "avm-demo-vnet"
  location            = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id
  address_space       = [var.address_space]

  subnets = {
    "private_endpoints" = {
      name             = "private-endpoints"
      address_prefixes = [cidrsubnet(var.address_space, 4, 0)]
    }
    "virtual_machines" = {
      name             = "virtual-machines"
      address_prefixes = [cidrsubnet(var.address_space, 4, 1)]
    }
  }
}


###############################################
#  PROVIDER
###############################################
provider "azurerm" {
 features {}
}
###############################################
#  NESTED MAP — PeopleSoft HCM + FS topology
###############################################
locals {
 peoplesoft = {
   dev = {
     hcm = {
       app  = 2
       web  = 2
       prcs = 2
     }
     fs = {
       app  = 2
       web  = 2
       prcs = 2
     }
   }
   tst = {
     hcm = {
       app  = 2
       web  = 2
       prcs = 2
     }
     fs = {
       app  = 2
       web  = 2
       prcs = 2
     }
   }
   pro = {
     hcm = {
       app  = 2
       web  = 2
       prcs = 2
     }
     fs = {
       app  = 2
       web  = 2
       prcs = 2
     }
   }
 }
}
###############################################
#  FLATTEN env → system → tier → server
###############################################
locals {
 servers = flatten([
   for env, systems in local.peoplesoft : [
     for system, tiers in systems : [
       for tier, count in tiers : [
         for i in range(count) : {
           env    = env
           system = system
           tier   = tier
           name   = "${env}-${system}-${tier}-${i + 1}"
         }
       ]
     ]
   ]
 ])
 server_map = {
   for s in local.servers :
   s.name => s
 }
}
###############################################
#  RESOURCE GROUPS — one per environment
###############################################
resource "azurerm_resource_group" "env" {
 for_each = {
   for env, _ in local.peoplesoft :
   env => env
 }
 name     = "rg-peoplesoft-${each.key}"
 location = "westus2"
}
###############################################
#  VIRTUAL NETWORK — shared
###############################################
resource "azurerm_virtual_network" "psft" {
 name                = "vnet-peoplesoft"
 address_space       = ["10.0.0.0/16"]
 location            = "westus2"
 resource_group_name = azurerm_resource_group.env["dev"].name
}
###############################################
#  SUBNETS — one per environment
###############################################
resource "azurerm_subnet" "psft" {
 for_each = {
   dev = "10.0.1.0/24"
   tst = "10.0.2.0/24"
   pro = "10.0.3.0/24"
 }
 name                 = "subnet-${each.key}"
 resource_group_name  = azurerm_resource_group.env["dev"].name
 virtual_network_name = azurerm_virtual_network.psft.name
 address_prefixes     = [each.value]
}
###############################################
#  LOAD BALANCERS — one per environment
###############################################
resource "azurerm_lb" "psft" {
 for_each = azurerm_resource_group.env
 name                = "lb-${each.key}"
 location            = "westus2"
 resource_group_name = each.value.name
 sku = "Standard"
 frontend_ip_configuration {
   name                          = "feip"
   subnet_id                     = azurerm_subnet.psft[each.key].id
   private_ip_address_allocation = "Dynamic"
 }
}
resource "azurerm_lb_backend_address_pool" "psft" {
 for_each = azurerm_lb.psft
 name            = "backendpool"
 loadbalancer_id = each.value.id
}
###############################################
#  NETWORK INTERFACES — one per server
###############################################
resource "azurerm_network_interface" "psft" {
 for_each = local.server_map
 name                = "${each.value.name}-nic"
 location            = "westus2"
 resource_group_name = azurerm_resource_group.env[each.value.env].name
 ip_configuration {
   name                          = "internal"
   subnet_id                     = azurerm_subnet.psft[each.value.env].id
   private_ip_address_allocation = "Dynamic"
 }
 tags = {
   env    = each.value.env
   system = each.value.system
   tier   = each.value.tier
 }
}
###############################################
#  LB BACKEND ASSOCIATION — app + web only
###############################################
resource "azurerm_network_interface_backend_address_pool_association" "psft" {
 for_each = {
   for k, v in local.server_map :
   k => v if v.tier == "app" || v.tier == "web"
 }
 network_interface_id    = azurerm_network_interface.psft[each.key].id
 ip_configuration_name   = "internal"
 backend_address_pool_id = azurerm_lb_backend_address_pool.psft[each.value.env].id
}
###############################################
#  VIRTUAL MACHINES — one per server
###############################################
resource "azurerm_linux_virtual_machine" "psft" {
 for_each = local.server_map
 name                = each.value.name
 resource_group_name = azurerm_resource_group.env[each.value.env].name
 location            = "westus2"
 # 4 cores, 32GB RAM, 500GB temp disk
 size = "Standard_D4s_v5"
 admin_username = "psadmin"
 network_interface_ids = [
   azurerm_network_interface.psft[each.key].id
 ]
 os_disk {
   caching              = "ReadWrite"
   storage_account_type = "Premium_LRS"
   disk_size_gb         = 1024  # 1TB OS disk
 }
 source_image_reference {
   publisher = "Oracle"
   offer     = "Oracle-Linux"
   sku       = "ol86-lvm"
   version   = "latest"
 }
 tags = {
   env    = each.value.env
   system = each.value.system
   tier   = each.value.tier
 }
}

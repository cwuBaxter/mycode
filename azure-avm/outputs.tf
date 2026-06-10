output "vnet_id" {
  description = "Resource ID of the deployed virtual network"
  value       = module.vnet.resource_id
}

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs"
  value       = { for k, v in module.vnet.subnets : k => v.resource_id }
}


output "resource_group_name" {
  description = "Navnet på den delte ressursgruppen."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "ID-en til den delte ressursgruppen."
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "Azure-regionen ressursene ligger i."
  value       = azurerm_resource_group.this.location
}

output "vnet_name" {
  description = "Navnet på det delte virtuelle nettverket."
  value       = module.vnet.name
}

output "vnet_id" {
  description = "ID-en til det delte virtuelle nettverket."
  value       = module.vnet.id
}

output "subnet_id" {
  description = "ID-en til tjenestens subnett."
  value       = module.subnet.subnet_id
}

output "storage_account_name" {
  description = "Navnet på tjenestens storage account."
  value       = module.storage.name
}

output "key_vault_name" {
  description = "Navnet på tjenestens Key Vault."
  value       = module.keyvault.name
}

output "vm_public_ip" {
  description = "Offentlig IP når tjenesten kjører som VM."
  value       = try(module.vm["this"].public_ip, null)
}

output "webapp_hostname" {
  description = "Hostname når tjenesten kjører som webapp."
  value       = try(module.webapp["this"].hostname, null)
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "shared_network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = var.state_container_name
    key                  = "oblig2/${var.miljo}/shared-network.tfstate"
    use_azuread_auth     = true
  }
}

locals {
  shared = data.terraform_remote_state.shared_network.outputs

  tags = {
    eier  = var.kortnavn
    miljo = var.miljo
    kurs  = "dcst3005-oblig2"
  }

  subnet_id   = "${local.shared.vnet_id}/subnets/snet-${var.service}"
  nsg_id      = "${local.shared.resource_group_id}/providers/Microsoft.Network/networkSecurityGroups/nsg-${var.service}"
  storage_id  = "${local.shared.resource_group_id}/providers/Microsoft.Storage/storageAccounts/st${var.kortnavn}${var.service}${var.miljo}"
  keyvault_id = "${local.shared.resource_group_id}/providers/Microsoft.KeyVault/vaults/kv-${var.kortnavn}-${var.service}-${var.miljo}"

  vm_instances     = var.runtime == "vm" ? { this = true } : {}
  webapp_instances = var.runtime == "webapp" ? { this = true } : {}
}

module "subnet" {
  source = "../../modules/subnet"

  service             = var.service
  resource_group_name = local.shared.resource_group_name
  location            = var.location
  vnet_name           = local.shared.vnet_name
  prefix              = var.prefix
  delegate_web        = var.runtime == "webapp"
  allow_http_from     = var.allow_http_from
  tags                = local.tags
}

module "storage" {
  source = "../../modules/storage"

  service             = var.service
  kortnavn            = var.kortnavn
  miljo               = var.miljo
  resource_group_name = local.shared.resource_group_name
  location            = var.location
  tags                = local.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  service             = var.service
  kortnavn            = var.kortnavn
  miljo               = var.miljo
  resource_group_name = local.shared.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

module "vm" {
  source   = "../../modules/vm"
  for_each = local.vm_instances

  service             = var.service
  resource_group_name = local.shared.resource_group_name
  location            = var.location
  subnet_id           = module.subnet.subnet_id
  size                = var.vm_size
  ssh_public_key      = var.ssh_public_key
  tags                = local.tags
}

module "webapp" {
  source   = "../../modules/webapp"
  for_each = local.webapp_instances

  service             = var.service
  kortnavn            = var.kortnavn
  miljo               = var.miljo
  resource_group_name = local.shared.resource_group_name
  location            = var.location
  subnet_id           = module.subnet.subnet_id
  sku                 = var.webapp_sku
  tags                = local.tags
}

import {
  to = module.subnet.azurerm_subnet.this
  id = local.subnet_id
}

import {
  to = module.subnet.azurerm_network_security_group.this
  id = local.nsg_id
}

import {
  to = module.subnet.azurerm_network_security_rule.http
  id = "${local.nsg_id}/securityRules/allow-http"
}

import {
  to = module.subnet.azurerm_subnet_network_security_group_association.this
  id = local.subnet_id
}

import {
  to = module.storage.azurerm_storage_account.this
  id = local.storage_id
}

import {
  to = module.keyvault.azurerm_key_vault.this
  id = local.keyvault_id
}

import {
  for_each = local.vm_instances
  to       = module.vm[each.key].azurerm_public_ip.this
  id       = "${local.shared.resource_group_id}/providers/Microsoft.Network/publicIPAddresses/pip-${var.service}"
}

import {
  for_each = local.vm_instances
  to       = module.vm[each.key].azurerm_network_interface.this
  id       = "${local.shared.resource_group_id}/providers/Microsoft.Network/networkInterfaces/nic-${var.service}"
}

import {
  for_each = local.vm_instances
  to       = module.vm[each.key].azurerm_linux_virtual_machine.this
  id       = "${local.shared.resource_group_id}/providers/Microsoft.Compute/virtualMachines/vm-${var.service}"
}

import {
  for_each = local.webapp_instances
  to       = module.webapp[each.key].azurerm_service_plan.this
  id       = "${local.shared.resource_group_id}/providers/Microsoft.Web/serverFarms/asp-${var.service}"
}

import {
  for_each = local.webapp_instances
  to       = module.webapp[each.key].azurerm_linux_web_app.this
  id       = "${local.shared.resource_group_id}/providers/Microsoft.Web/sites/app-${var.kortnavn}-${var.service}-${var.miljo}"
}

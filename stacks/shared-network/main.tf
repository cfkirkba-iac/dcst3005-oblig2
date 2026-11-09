locals {
  resource_group_name = "rg-${var.kortnavn}-oblig2-${var.miljo}"
  vnet_name           = "vnet-${var.kortnavn}-${var.miljo}"

  tags = {
    eier  = var.kortnavn
    miljo = var.miljo
    kurs  = "dcst3005-oblig2"
  }
}

# Brukes kun til å bygge import-ID-er uten hardkodet subscription-ID.
data "azurerm_resource_group" "existing" {
  name = local.resource_group_name
}

data "azurerm_virtual_network" "existing" {
  name                = local.vnet_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.address_space
  tags                = local.tags
}

import {
  to = azurerm_resource_group.this
  id = data.azurerm_resource_group.existing.id
}

import {
  to = module.vnet.azurerm_virtual_network.this
  id = data.azurerm_virtual_network.existing.id
}

resource "azurerm_resource_group" "hub_rg" {
  name     = "enterprise-networking-hubs-rg"
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "example-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = ["10.200.0.0/24"]
}

resource "azurerm_resource_group" "spoke_rg" {
  name     = "enterprise-networking-spokes-rg"
  location = var.location
}
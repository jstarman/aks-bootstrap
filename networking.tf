# Hub
resource "azurerm_resource_group" "hub_vnet_rg" {
  name     = "enterprise-networking-hubs-rg"
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "example-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = ["10.200.0.0/24"]
}

resource "azurerm_subnet" "hub-firewall-subnet" {
    name                 = "FirewallSubnet"
    resource_group_name  = azurerm_resource_group.hub_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes     = ["10.200.0.0/26"]
}

resource "azurerm_subnet" "hub-gateway-subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.hub_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes     = ["10.200.0.64/27"]
}

resource "azurerm_subnet" "hub-bastion-subnet" {
    name                 = "BastionSubnet"
    resource_group_name  = azurerm_resource_group.hub_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes     = ["10.200.0.96/27"]
}

resource "azurerm_public_ip" "hub-gateway-pip" {
    name                = "hub-gateway-pip"
    location            = var.location
    resource_group_name = azurerm_resource_group.hub_rg.name
    allocation_method   = "Static"
    ip_version          = "IPv4"
    sku                 = "Standard"
}

resource "azurerm_ip_group" "aks_node_pools_ipg" {
  name                = "AksNodesIPgroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
# az deployment group show -g enterprise-networking-spokes-rg -n [spoke-subnet-name] --query properties.outputs.nodepoolSubnetResourceIds.value -o tsv
#  cidrs = ["192.168.0.1", "172.16.240.0/20", "10.48.0.0/12"]

}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "HubFirewallPolicy"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  base_policy_id      = var.base_policy_id
  sku                 = var.sku
  dns {
    proxy_enabled = var.dns_proxy_enabled
    servers       = var.dns_servers_list
  }
  threat_intelligence_mode = var.threat_intelligence_mode
}

resource "azurerm_firewall" "hub_firewall" {
  name                = "HubFirewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  # zones overkill for now https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  firewall_policy_id  = var.firewall_policy_id

  ip_configuration {
    name                 = "${var.name}-PublicIP"
    subnet_id            = azurerm_subnet.hub-firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-gateway-pip.id
  }
}


# Spoke
resource "azurerm_resource_group" "spoke_rg" {
  name     = "enterprise-networking-spokes-rg"
  location = var.location
}
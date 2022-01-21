terraform {
  required_version = ">= 0.14.9"

  backend "azurerm" {
    key = "tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.91.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "aks_platform_rg" {
  name     = var.platform_resource_group
  location = var.location
  tags     = var.tags
}

module "log_analytics_workspace" {
  source                           = "./modules/log_analytics"
  name                             = var.log_analytics_workspace_name
  location                         = var.location
  resource_group_name              = azurerm_resource_group.aks_platform_rg.name
  solution_plan_map                = var.solution_plan_map
}

module "hub_network" {
  source                       = "./modules/virtual_network"
  resource_group_name          = azurerm_resource_group.aks_platform_rg.name
  location                     = var.location
  vnet_name                    = var.hub_vnet_name
  address_space                = var.hub_address_space
  tags                         = var.tags
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days

  subnets = [
    {
      name : "AzureFirewallSubnet"
      address_prefixes : var.hub_firewall_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : "AzureBastionSubnet"
      address_prefixes : var.hub_bastion_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    }
  ]
}

module "aks_network" {
  source                       = "./modules/virtual_network"
  resource_group_name          = azurerm_resource_group.aks_platform_rg.name
  location                     = var.location
  vnet_name                    = var.aks_vnet_name
  address_space                = var.aks_vnet_address_space
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days

  subnets = [
    {
      name : var.default_node_pool_subnet_name
      address_prefixes : var.default_node_pool_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : var.additional_node_pool_subnet_name
      address_prefixes : var.additional_node_pool_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : var.vm_subnet_name
      address_prefixes : var.vm_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    }
  ]
}

module "vnet_peering" {
  source              = "./modules/virtual_network_peering"
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.hub_network.vnet_id
  vnet_1_rg           = azurerm_resource_group.aks_platform_rg.name
  vnet_2_name         = var.aks_vnet_name
  vnet_2_id           = module.aks_network.vnet_id
  vnet_2_rg           = azurerm_resource_group.aks_platform_rg.name
  peering_name_1_to_2 = "${var.hub_vnet_name}To${var.aks_vnet_name}"
  peering_name_2_to_1 = "${var.aks_vnet_name}To${var.hub_vnet_name}"
}

# $1.25 per deployment hour plus $0.016 per GB processed
module "firewall" {
  source                       = "./modules/firewall"
  name                         = var.firewall_name
  resource_group_name          = azurerm_resource_group.aks_platform_rg.name
  zones                        = var.firewall_zones
  threat_intel_mode            = var.firewall_threat_intel_mode
  location                     = var.location
  sku_tier                     = var.firewall_sku_tier
  pip_name                     = "${var.firewall_name}PublicIp"
  subnet_id                    = module.hub_network.subnet_ids["AzureFirewallSubnet"]
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "routetable" {
  source               = "./modules/route_table"
  resource_group_name  = azurerm_resource_group.aks_platform_rg.name
  location             = var.location
  route_table_name     = "DefaultRouteTable"
  route_name           = "RouteToAzureFirewall"
  firewall_private_ip  = module.firewall.private_ip_address
  subnets_to_associate = {
    (var.default_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = azurerm_resource_group.aks_platform_rg.name
      virtual_network_name = module.aks_network.name
    }
    (var.additional_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = azurerm_resource_group.aks_platform_rg.name
      virtual_network_name = module.aks_network.name
    }
  }
}

module "container_registry" {
  source                       = "./modules/container_registry"
  name                         = var.acr_name
  resource_group_name          = azurerm_resource_group.aks_platform_rg.name
  location                     = var.location
  sku                          = var.acr_sku
  admin_enabled                = var.acr_admin_enabled
  georeplication_locations     = var.acr_georeplication_locations
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "ad_group" {
  source                 = "./modules/ad_group"
  cluster_admin_username = var.cluster_admin_username
}

# default node pool VM skus
# Standard_A2_v2 $55.48/month
# Standard_DS2_v2 $83.22/month
module "aks_cluster" {
  source                                   = "./modules/aks"
  name                                     = var.aks_cluster_name
  location                                 = var.location
  resource_group_name                      = azurerm_resource_group.aks_platform_rg.name
  resource_group_id                        = azurerm_resource_group.aks_platform_rg.id
  kubernetes_version                       = var.kubernetes_version
  tags                                     = var.tags
  dns_prefix                               = lower(var.aks_cluster_name)
  private_cluster_enabled                  = true
  automatic_channel_upgrade                = var.automatic_channel_upgrade
  sku_tier                                 = var.sku_tier
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type
  vnet_subnet_id                           = module.aks_network.subnet_ids[var.default_node_pool_subnet_name]
  network_docker_bridge_cidr               = var.network_docker_bridge_cidr
  network_service_cidr                     = var.network_service_cidr
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  outbound_type                            = "userDefinedRouting"
  log_analytics_workspace_id               = module.log_analytics_workspace.id
  role_based_access_control_enabled        = var.role_based_access_control_enabled
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                   = ["${module.ad_group.aks_cluster_admin_group_id}"]
  azure_rbac_enabled                       = var.azure_rbac_enabled
  admin_username                           = var.cluster_admin_username
  ssh_public_key                           = file(var.ssh_public_key_path)
  depends_on                               = [module.routetable]
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.aks_platform_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name = "AcrPull"
  scope                = module.container_registry.id
  principal_id         = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

# Generate random name for storage account
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  number  = false
}

module "storage_account" {
  source                      = "./modules/storage_account"
  name                        = "vmvolume${random_string.storage_account_suffix.result}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.aks_platform_rg.name
  account_kind                = var.storage_account_kind
  account_tier                = var.storage_account_tier
  replication_type            = var.storage_account_replication_type
}

# $0.19 per hour plus outbound data transfer
module "bastion_host" {
  source                       = "./modules/bastion_host"
  name                         = var.bastion_host_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.aks_platform_rg.name
  subnet_id                    = module.hub_network.subnet_ids["AzureBastionSubnet"]
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

# Standard_DS1_v2 $41.61/month
# Jump box
# module "virtual_machine" {
#   source                              = "./modules/virtual_machine"
#   name                                = var.vm_name
#   size                                = var.vm_size
#   location                            = var.location
#   public_ip                           = var.vm_public_ip
#   vm_user                             = var.admin_username
#   admin_ssh_public_key                = file(var.ssh_public_key_path)
#   os_disk_image                       = var.vm_os_disk_image
#   domain_name_label                   = var.domain_name_label
#   resource_group_name                 = azurerm_resource_group.aks_platform_rg.name
#   subnet_id                           = module.aks_network.subnet_ids[var.vm_subnet_name]
#   os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
#   boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
#   log_analytics_workspace_id          = module.log_analytics_workspace.workspace_id
#   log_analytics_workspace_key         = module.log_analytics_workspace.primary_shared_key
#   log_analytics_workspace_resource_id = module.log_analytics_workspace.id
#   log_analytics_retention_days        = var.log_analytics_retention_days
#   script_storage_account_name         = var.script_storage_account_name
#   script_storage_account_key          = var.script_storage_account_key
#   container_name                      = var.container_name
#   script_name                         = var.script_name
# }
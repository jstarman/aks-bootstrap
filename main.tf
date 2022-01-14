terraform {
  required_version = ">= 0.13"

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
      version = "~> 2.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

# TF backend objects created via bootstrap

resource "azurerm_resource_group" "infra_state_rg" {
  name     = var.infra_resource_group
  location = var.location
}

resource "azurerm_storage_account" "state_storage" {
  name                      = var.infra_storage_account
  resource_group_name       = azurerm_resource_group.infra_state_rg.name
  location                  = azurerm_resource_group.infra_state_rg.location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
}

# Start AKS Setup

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
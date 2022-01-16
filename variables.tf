variable "location" {
  description = "Region used for all resources"
  type        = string
  default     = "westus2"
}

variable "infra_resource_group" {
  description = "Shared management resource group"
  type        = string
}

variable "infra_storage_account" {
  description = "Storage to store the state file"
  type        = string
}

variable "cluster_admin_username" {
  description = "AKS Cluster Admin Service Principal"
  type        = string
}

variable "platform_resource_group" {
  default     = "aks-platform-rg"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {
    env = "dev"
  }
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  type        = string
  default     = "AksWorkspace"
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  type = map(any)
  default     = {
    ContainerInsights= {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
}

variable "hub_vnet_name" {
  description = "Specifies the name of the hub virtual virtual network"
  type        = string
  default     = "HubVNet"
}

variable "hub_address_space" {
  description = "Specifies the address space of the hub virtual virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]

}

variable "hub_firewall_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  type        = list(string)
  default     = ["10.1.0.0/24"]
}

variable "hub_bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "aks_vnet_name" {
  description = "Specifies the name of the AKS subnet"
  type        = string
  default     = "AksVNet"
}

variable "aks_vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  type        = list(string)
  default     =  ["10.0.0.0/16"]
}

variable "default_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  type        = string
  default     =  "SystemSubnet"
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the default node pool"
  type        = list(string)
  default     =  ["10.0.0.0/21"]
}

variable "additional_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  type        = string
  default     =  "UserSubnet"
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the additional node pool"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "vm_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  type        = string
  default     = "VmSubnet"
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumbox subnet"
  type        = list(string)
  default     = ["10.0.8.0/21"]
}
variable "firewall_name" {
  description = "Specifies the name of the Azure Firewall"
  type        = string
  default     = "AksFirewall"
}

variable "firewall_zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "firewall_threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  type        = string
  default     = "Alert"

  validation {
    condition = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "firewall_sku_tier" {
  description = "Specifies the SKU tier of the Azure Firewall"
  type        = string
  default     = "Standard"
}

variable "acr_name" {
  description = "Specifies the name of the container registry (needs to be globally unique)"
  type        = string
  default     = "AksAcr"
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Basic"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}
variable "location" {
  type        = string
  description = "Region used for all resources"
}

variable "infra_resource_group" {
  type        = string
  description = "Shared management resource group"
}

variable "infra_storage_account" {
  type        = string
  description = "Storage to store the state file"
}

variable "cluster_admin_username" {
  type        = string
  description = "AKS Cluster Admin Service Principal"
}

# former resource_group_name
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
  default     = "AksWorkspace"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default     = {
    ContainerInsights= {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
  type = map(any)
}
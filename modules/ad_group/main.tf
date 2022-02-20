# Create AKS Cluster Admin Group and add SP to the group

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.91.0"
    }
  }

  required_version = ">= 0.14.9"
}

# data "azuread_user" "aks_cluster_admin_sp" {
#   user_principal_name = var.cluster_admin_username
# }

resource "azuread_group" "aks_cluster_admin_group" {
  display_name     = "${var.tag}_${var.cluster_name}_Admin"
  description      = "${var.tag}_${var.cluster_name} K8s administrators."
  security_enabled = true
}

resource "azuread_group_member" "add_user" {
  group_object_id  = azuread_group.aks_cluster_admin_group.id
  member_object_id = var.current_user_object_id
}

# resource "azuread_group_member" "add_user" {
#   group_object_id  = azuread_group.aks_cluster_admin_group.id
#   member_object_id = data.azuread_user.aks_cluster_admin_sp.id
# }
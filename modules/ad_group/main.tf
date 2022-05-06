# Create AD Group and add supplied user to the group

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.5.0"
    }
  }

  required_version = ">= 1.1.2"
}

resource "azuread_group" "aks_cluster_admin_group" {
  display_name     = "${var.environment}_${var.group_name}"
  description      = "${var.environment } ${var.description}"
  security_enabled = true
}

resource "azuread_group_member" "add_user" {
  group_object_id  = azuread_group.aks_cluster_admin_group.id
  member_object_id = var.current_user_object_id
}
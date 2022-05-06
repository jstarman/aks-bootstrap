# Setup Argo CD SSO

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.5.0"
    }
  }

  required_version = ">= 1.1.2"
}

# resource "random_uuid" "id" {
# }

resource "azuread_application" "app" {
  display_name            = var.display_name
  group_membership_claims = ["ApplicationGroup"]

  web {
    redirect_uris = ["https://${var.argocd_server}/argo-cd/auth/callback"]

    implicit_grant {
      access_token_issuance_enabled = false
    }
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Admins can perform all task actions"
    display_name         = "Admin"
    enabled              = true
    id                   = "00000000-0000-0000-0000-222222222222"
    value                = "Admin.All"
  }

  # Not sure if this is needed
  # api {
  #   oauth2_permission_scope {
  #     admin_consent_description  = "Allow the application access on behalf of the signed-in user."
  #     admin_consent_display_name = "Admin Access"
  #     enabled                    = false
  #     id                         = random_uuid.id.result
  #     type                       = "User"
  #   }
  # }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"  # MS Graph app id.

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" #User.Read consent to sign in and read user profile
      type = "Scope"
    }
  }

  optional_claims {
    access_token {
      name = "groups"
    }

    id_token {
      name = "groups"
    }

    saml2_token {
      name = "groups"
    }
  }

  tags = ["WindowsAzureActiveDirectoryIntegratedApp"]
}

resource "azuread_service_principal" "internal" {
  application_id = azuread_application.app.application_id
}

# If on azure AD premium switch out current user for AD group.
# principal_object_id = var.devops_admin_group_object_id
resource "azuread_app_role_assignment" "current_user" {
  app_role_id         = azuread_application.app.app_role_ids["Admin.All"]
  principal_object_id = var.current_user_object_id
  resource_object_id  = azuread_service_principal.internal.object_id
}
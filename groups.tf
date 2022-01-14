# data "azuread_user" "aks_cluster_admin_sp" {
#   user_principal_name = var.cluster_admin_username
# }

# resource "azuread_group" "aks_cluster_admin_group" {
#   display_name     = "AKSClusterAdmin"
#   mail_nickname    = "aksclusteradmingroup"
#   security_enabled = true
# }

# resource "azuread_group_member" "add_user" {
#   group_object_id  = azuread_group.aks_cluster_admin_group.id
#   member_object_id = data.azuread_user.aks_cluster_admin_sp.id
# }

# output "aksclusteradmingroup" {
#   value = azuread_group.aks_cluster_admin_group.object_id
# }
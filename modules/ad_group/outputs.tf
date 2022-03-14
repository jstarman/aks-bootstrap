output "devops_admin_group_object_id" {
  value       = azuread_group.aks_cluster_admin_group.object_id
  description = "Object ID of Azure Active Directory Group"
}

variable "display_name" {
  description = "Name of AD application"
  type        = string
}

variable "argocd_server" {
  description = "Name of Argo CD server"
  type        = string
}

variable "devops_admin_group_object_id" {
  description = "Dev Ops admin group object id"
  type        = string
}

variable "current_user_object_id" {
  description = "Current users object id to add to AKS admin group"
  type        = string
}
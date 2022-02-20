variable "cluster_admin_username" {
  description = "AKS Cluster Admin Service Principal"
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "tag" {
  type = string
}

variable "current_user_object_id" {
  description = "Current users object id to add to AKS admin group"
  type        = string
}
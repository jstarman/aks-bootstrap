variable "group_name" {
  description = "Name of AD group"
  type        = string
}

variable "environment" {
  description = "Environment the AD group will be applied"
  type        = string
}

variable "description"{
  description = "AD group description"
  type        = string
}

variable "current_user_object_id" {
  description = "Current users object id to add to AKS admin group"
  type        = string
}
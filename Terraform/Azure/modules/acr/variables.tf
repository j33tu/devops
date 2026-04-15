variable "name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region (e.g., East US)"
  default     = "East US"
}
variable "admin_enabled" {
  type        = bool
  description = "Whether to enable admin access to the container registry"
  default     = true
}
variable "sku" {
  type        = string
  description = "The SKU of the container registry (Basic, Standard, Premium)"
}
variable "resource_group_name" {
  type        = string
  description = "resource group name wher aks will be deployed"
}

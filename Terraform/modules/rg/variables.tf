variable "rg_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region (e.g., East US)"
  default     = "East US"
}

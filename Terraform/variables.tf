variable "mysql_password" {
  type      = string
  sensitive = true
}
variable "mysql_db_password" {
  type      = string
  sensitive = true
}
variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))

  default = {
    "network_hub" = {
      name     = "rg-connectivity-prod"
      location = "Central India"
      tags     = { "Department" = "IT", "Criticality" = "High" }
    },
    "vdi_project" = {
      name     = "rg-autocad-vdi"
      location = "West US"
      tags     = { "Project" = "AutoCAD-VDI", "Owner" = "Jitendra" }
    },
    "monitoring" = {
      name     = "rg-mgmt-monitoring"
      location = "East US"
      tags     = { "App" = "LogAnalytics" }
    },
    "data" = {
      name     = "rg-data-prod"
      location = "westus3"
      tags     = { "Department" = "Data", "Criticality" = "High" }
    }
  }
}

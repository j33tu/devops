provider "azurerm" {
  features {}
}
module "network_rg" {
  source = "./modules/rg"

  rg_name = "rg-prod-networking"


  location = "West US"
}
module "app_rg" {
  source = "./modules/rg"

  rg_name  = "rg-prod-applications"
  location = "East US"
}

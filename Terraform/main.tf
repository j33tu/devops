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
module "app_rga" {
  source = "./modules/rg"

  rg_name  = "rg-dev-applications"
  location = "East US"
}
module "app_rga12" {
  source = "./modules/rg"

  rg_name  = "rg-dev1-applications"
  location = "East US"
}

module "app_rga13" {
  source = "./modules/rg"

  rg_name  = "rg-dev2-applications"
  location = "East US"
}

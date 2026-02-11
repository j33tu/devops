provider "azurerm" {
  features {}
}
terraform {
  backend "azurerm" {
    resource_group_name  = "compute"
    storage_account_name = "g2tfstatestorage" # Use your actual name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
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
module "app_rga14" {
  source = "./modules/rg"

  rg_name  = "rg-g2-applications"
  location = "East US"
}
module "app_rga15" {
  source = "./modules/rg"

  rg_name  = "rg-g212-applications"
  location = "East US"
}

module "app_rga16" {
  source = "./modules/rg"

  rg_name  = "rg-g2-vdi"
  location = "East US"
}

# --- Provider & Backend Configuration ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "compute"
    storage_account_name = "g2tfstatestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# --- 1. Infrastructure Resource Group ---
resource "azurerm_resource_group" "cdn_rg" {
  name     = "rg-cricket-cdn-prod"
  location = "West US 2"
}

# --- 2. Database Module ---
module "mysql_db" {
  source              = "./modules/mysql"
  server_name         = "g2-prd-mysql-wus"
  resource_group_name = "compute"
  location            = "westus3"
  admin_username      = "g2admin"
  admin_password      = var.mysql_password
  db_name             = "app_db"
}



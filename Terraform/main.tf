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
  features {
    resource_group {
      # This allows Terraform to delete the RG even if it contains 
      # "rogue" resources like those Prometheus rules.
      prevent_deletion_if_contains_resources = false
    }
  }
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


resource "azurerm_resource_group" "this" {
  # for each for resource groups 
  for_each = var.resource_groups
  name     = each.value.name
  location = each.value.location
  tags     = each.value.tags
}


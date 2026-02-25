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

module "mysql_db" {
  source              = "./modules/mysql"
  server_name         = "g2-prd-mysql-wus"
  resource_group_name = "compute" # Use one created by your RG module
  location            = "westus3"
  admin_username      = "g2admin"
  admin_password      = var.mysql_password # Pass this from GitLab CI Secrets
  db_name             = "app_db"
}





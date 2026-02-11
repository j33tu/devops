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

module "mysql_db" {
  source              = "./modules/mysql"
  server_name         = "g2-prd-mysql-wus"
  resource_group_name = "compute" # Use one created by your RG module
  location            = "westus3"
  admin_username      = "g2admin"
  admin_password      = var.mysql_password # Pass this from GitLab CI Secrets
  db_name             = "app_db"
}

# 1. Firewall Rule to let the Web App reach the DB .
# (Crucial: 0.0.0.0 is the special range that tells Azure to allow its own services)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = "compute"
  server_name         = "g2-prd-mysql-wus" # Matches your DB server name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# 2. App Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "g2-python-app-plan"
  resource_group_name = "compute"
  location            = "westus3"
  os_type             = "Linux"
  sku_name            = "B1"
}

# 3. The Linux Web App
resource "azurerm_linux_web_app" "python_webapp" {
  name                = "g2-python-app-name"
  resource_group_name = "compute"
  location            = "westus3"
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
    # For Python apps, ensure your entry point is set if not using app.py
    # app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 main:app"
  }

  app_settings = {
    "DBHOST"                         = "g2-prd-mysql-wus.mysql.database.azure.com"
    "DBNAME"                         = "dirtyvehicleplate_2025"
    "DBUSER"                         = "g2admin"
    "DBPASS"                         = var.mysql_db_password
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
  }

  connection_string {
    name  = "Database"
    type  = "MySql"
    value = "Database=dirtyvehicleplate_2025;Data Source=g2-prd-mysql-wus.mysql.database.azure.com;User Id=g2admin;Password=${var.mysql_db_password};Port=3306;SslMode=Required"
  }

}

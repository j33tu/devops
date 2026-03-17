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


# deploy resource group for k8s cluster

resource "azurerm_resource_group" "k8srg" {
  name     = "k8s-rg"
  location = "westus2"
}
module "acr" {
  source              = "./modules/acr"
  name                = "g2acr" # Must be globally unique
  resource_group_name = azurerm_resource_group.k8srg.name
  location            = azurerm_resource_group.k8srg.location
  sku                 = "Basic"
  admin_enabled       = true
}


# deploy aks cluster in one

module "aks" {
  source              = "./modules/aks"
  name                = "g2k8s_Cluster"
  location            = azurerm_resource_group.k8srg.location
  resource_group_name = azurerm_resource_group.k8srg.name
  dns_prefix          = "g2k8s"
  default_node_pool = {
    name       = "default"
    node_count = 2
    vm_size    = "standard_b16als_v2"
  }
  identity = "SystemAssigned"
}

resource "azurerm_role_assignment" "aks_to_acr" {
  # We reference the module name, then the output name defined above
  principal_id = module.aks.kubelet_identity_id
  scope        = module.acr.acr_id

  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}

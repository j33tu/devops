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

# --- 3. Storage Account (The Origin) ---
resource "azurerm_storage_account" "website_storage" {
  name                     = "stparakramwebprod"
  resource_group_name      = azurerm_resource_group.cdn_rg.name
  location                 = azurerm_resource_group.cdn_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Required for modern Front Door access
  allow_nested_items_to_be_public = true
}

# Separate resource for Static Website functionality
resource "azurerm_storage_account_static_website" "website_static" {
  storage_account_id = azurerm_storage_account.website_storage.id
  index_document     = "index.html"
  error_404_document = "index.html"
}

# --- 4. Azure Front Door Profile ---
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-parakram-global"
  resource_group_name = azurerm_resource_group.cdn_rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

# --- 5. Front Door Endpoint ---
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "parakram-live"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

# --- 6. Origin Group & Health Probe ---
resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                     = "og-storage"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {}

  health_probe {
    interval_in_seconds = 100
    protocol            = "Https"
    request_type        = "GET"
  }
}

# --- 7. Origin (Host Header Fix) ---
resource "azurerm_cdn_frontdoor_origin" "storage_origin" {
  name                          = "origin-storage"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id

  host_name          = azurerm_storage_account.website_storage.primary_web_host
  origin_host_header = azurerm_storage_account.website_storage.primary_web_host

  certificate_name_check_enabled = true
  enabled                        = true
}

# --- 8. Route (Final Fixed Mapping) ---
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.storage_origin.id]

  supported_protocols = ["Http", "Https"]
  patterns_to_match   = ["/*"]
  forwarding_protocol = "HttpsOnly"

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true

    content_types_to_compress = [
      "application/eot",
      "application/font",
      "application/font-sfnt",
      "application/javascript",
      "application/json",
      "application/opentype",
      "application/otf",
      "application/pkcs7-mime",
      "application/truetype",
      "application/ttf",
      "application/vnd.ms-fontobject",
      "application/xhtml+xml",
      "application/xml",
      "text/css",
      "text/csv",
      "text/html",
      "text/javascript",
      "text/js",
      "text/plain",
      "text/xml"
    ]
  }
}

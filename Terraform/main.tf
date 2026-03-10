provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "compute"
    storage_account_name = "g2tfstatestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# --- Database Module ---
module "mysql_db" {
  source              = "./modules/mysql"
  server_name         = "g2-prd-mysql-wus"
  resource_group_name = "compute"
  location            = "westus3"
  admin_username      = "g2admin"
  admin_password      = var.mysql_password
  db_name             = "app_db"
}

# --- 1. Resource Group ---
resource "azurerm_resource_group" "cdn_rg" {
  name     = "rg-cricket-cdn-prod"
  location = "West US 2"
}

# --- 2. Storage Account (The Origin) ---
resource "azurerm_storage_account" "website_storage" {
  name                     = "stparakramwebprod"
  resource_group_name      = azurerm_resource_group.cdn_rg.name
  location                 = azurerm_resource_group.cdn_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "website_static" {
  storage_account_id = azurerm_storage_account.website_storage.id
  index_document     = "index.html"
}

# --- 3. Azure Front Door Profile ---
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-parakram-global"
  resource_group_name = azurerm_resource_group.cdn_rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

# --- 4. Front Door Endpoint ---
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "parakram-live"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

# --- 5. Origin Group and Origin ---
resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                     = "og-storage"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {}

  health_probe {
    interval_in_seconds = 100
    protocol            = "Https"
    request_type        = "GET" # Standard for static sites
  }
}

resource "azurerm_cdn_frontdoor_origin" "storage_origin" {
  name                          = "origin-storage"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id
  # Use primary_web_host for the static website endpoint
  host_name                      = azurerm_storage_account.website_storage.primary_web_host
  origin_host_header             = azurerm_storage_account.website_storage.primary_web_host
  certificate_name_check_enabled = true
}

# --- 6. Route (With Fix for Compression Error) ---
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.og.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.storage_origin.id]
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true

    # FIXED: Mandatory list when compression is enabled
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

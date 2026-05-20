packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.0.0"
    }
  }
}
#location = "East US"
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

source "azure-arm" "windows" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  managed_image_resource_group_name = "compute"
  managed_image_name                = "win-golden-image"
  location = "East US"
  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter"

  vm_size = "Standard_D2s_v3"
  virtual_network_name                = "vnet-southindia"
virtual_network_subnet_name         = "snet-southindia-1"
virtual_network_resource_group_name = "compute"
private_virtual_network_with_public_ip = false
}

build {
  name    = "windows-golden-image"
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    script = "./scripts/installchrome.ps1"
  }


  provisioner "powershell" {
    script = "./scripts/sysprep.ps1"
  }
}
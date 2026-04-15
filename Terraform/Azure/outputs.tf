output "rg_names" {
  value = [for rg in azurerm_resource_group.this : rg.name]
}

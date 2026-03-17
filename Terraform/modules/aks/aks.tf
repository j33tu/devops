resource "azurerm_kubernetes_cluster" "aks" {
  name                = "g2k8s_Cluster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  default_node_pool {
    name       = var.default_node_pool.name
    node_count = var.default_node_pool.node_count
    vm_size    = var.default_node_pool.vm_size
  }
  identity {
    type = var.identity
  }
}

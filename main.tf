provider "azurerm" {
  features {}
}

#----------------------------------------------------------------------------------------
# resource groups
#----------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  for_each = var.aks

  name     = each.value.config.resourcegroup
  location = each.value.config.location
}

#----------------------------------------------------------------------------------------
# aks cluster
#----------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks

  name                = "demo-aks1"
  location            = each.value.config.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  dns_prefix          = "demoaks1"

  default_node_pool {
    name       = "default"
    node_count = each.value.default_node_pool.count
    vm_size    = each.value.default_node_pool.vmsize
  }

  identity {
    type = "SystemAssigned"
  }
}
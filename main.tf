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
    zones      = each.value.config.zones
  }

  identity {
    type = "SystemAssigned"
  }
}

#----------------------------------------------------------------------------------------
# node pools
#----------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "pools" {
  for_each = {
    for pools in local.aks_pools : "${pools.aks_key}.${pools.pools_key}" => pools
  }

  name                  = each.value.poolname
  kubernetes_cluster_id = each.value.aks_cluster_id
  vm_size               = each.value.vmsize
  node_count            = each.value.count
}
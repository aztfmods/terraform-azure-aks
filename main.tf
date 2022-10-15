#----------------------------------------------------------------------------------------
# resourcegroups
#----------------------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  for_each = var.aks

  name = each.value.resourcegroup
}

#----------------------------------------------------------------------------------------
# aks cluster
#----------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks

  name                = "aks-${var.naming.company}-${each.key}-${var.naming.env}-${var.naming.region}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location
  dns_prefix          = "demoaks1"

  default_node_pool {
    name       = "default"
    vm_size    = each.value.default_node_pool.vmsize
    node_count = each.value.default_node_pool.node_count
    max_count  = try(each.value.default_node_pool.max_count, null)
    max_pods   = try(each.value.default_node_pool.max_pods, 30)
    min_count  = try(each.value.default_node_pool.min_count, null)
    zones      = try(each.value.default_node_pool.zones, [])

    enable_auto_scaling          = try(each.value.default_node_pool.enable.auto_scaling, false)
    enable_host_encryption       = try(each.value.default_node_pool.enable.host_encryption, false)
    enable_node_public_ip        = try(each.value.default_node_pool.enable.node_public_ip, false)
    fips_enabled                 = try(each.value.default_node_pool.enable.fips, null)
    only_critical_addons_enabled = try(each.value.default_node_pool.enable.only_critical_addons, false)
    node_labels                  = try(each.value.default_node_pool.node_labels, null)
    os_sku                       = try(each.value.default_node_pool.os_sku, null)
    type                         = try(each.value.default_node_pool.type, "VirtualMachineScaleSets")
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
  max_count             = try(each.value.max_count, null)
  min_count             = try(each.value.min_count, null)
  node_count            = try(each.value.node_count, null)

  zones                  = try(each.value.availability_zones, null)
  enable_auto_scaling    = try(each.value.enable.auto_scaling, false)
  enable_host_encryption = try(each.value.enable.host_encryption, false)
  enable_node_public_ip  = try(each.value.enable.node_public_ip, false)
  fips_enabled           = try(each.value.enable.fips, false)
  eviction_policy        = try(each.value.eviction_policy, null)
  kubelet_disk_type      = try(each.value.kubelet_disk_type, null)
  max_pods               = try(each.value.max_pods, null)
  mode                   = try(each.value.mode, "User")
  node_labels            = try(each.value.node_labels, null)
  node_taints            = try(each.value.node_taints, null)
  os_sku                 = try(each.value.os_sku, null)
  os_type                = try(each.value.os_type, null)
  priority               = try(each.value.priority, null)
}
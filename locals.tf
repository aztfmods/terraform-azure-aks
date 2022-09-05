locals {
  aks_pools = flatten([
    for aks_key, aks in var.aks : [
      for pools_key, pools in try(aks.node_pools, {}) : {

        aks_key        = aks_key
        pools_key      = pools_key
        vmsize         = pools.vmsize
        count          = pools.count
        poolname       = "aks${pools_key}"
        aks_cluster_id = azurerm_kubernetes_cluster.aks[aks_key].id
      }
    ]
  ])
}
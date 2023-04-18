locals {
  aks_pools = flatten([
    for pools_key, pools in try(var.aks.node_pools, {}) : {
      pools_key        = pools_key
      vmsize           = pools.vmsize
      count            = pools.node_count
      max_surge        = pools.max_surge
      poolname         = "aks${pools_key}"
      aks_cluster_id   = azurerm_kubernetes_cluster.aks.id
      linux_os_config  = try(pools.config.linux_os, {})
      kubelet_config   = try(pools.config.kubelet, {})
      workload_runtime = try(pools.workload_runtime, null)
    }
  ])
}

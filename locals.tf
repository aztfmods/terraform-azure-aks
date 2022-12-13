locals {
  aks_pools = flatten([
    for aks_key, aks in var.aks : [
      for pools_key, pools in try(aks.node_pools, {}) : {

        aks_key        = aks_key
        pools_key      = pools_key
        vmsize         = pools.vmsize
        count          = pools.node_count
        max_surge      = pools.max_surge
        poolname       = "aks${pools_key}"
        aks_cluster_id = azurerm_kubernetes_cluster.aks[aks_key].id
      }
    ]
  ])
}

locals {
  aks_roles = flatten([
    for aks_key, aks in var.aks : [
      for roles_key, roles in try(aks.role_assignment, []) : {

        aks_key                          = aks_key
        roles_key                        = roles_key
        principal_id                     = azurerm_kubernetes_cluster.aks[aks.key].kubelet_identity[0].object_id
        skip_service_principal_aad_check = try(roles.skip_service_principal_aad_check, true)
        scope                            = roles.scope
      }
    ]
  ])
}
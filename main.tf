#----------------------------------------------------------------------------------------
# aks cluster
#----------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {

  name                = "aks-${var.company}-${var.env}-${var.region}"
  resource_group_name = var.aks.resourcegroup
  location            = var.aks.location

  kubernetes_version        = try(var.aks.version, null)
  sku_tier                  = try(var.aks.sku, "Free")
  node_resource_group       = try(var.aks.node_resource_group, [])
  azure_policy_enabled      = try(var.aks.enable.azure_policy, false)
  dns_prefix                = try(var.aks.dns_prefix, false)
  automatic_channel_upgrade = try(var.aks.channel_upgrade, null)

  dynamic "network_profile" {
    for_each = {
      for k, v in try(var.aks.network_profile, {}) : k => v
    }

    content {
      network_plugin     = try(network_profile.value.network_plugin, null)
      network_mode       = try(network_profile.value.network_mode, null)
      network_policy     = try(network_profile.value.network_policy, null)
      dns_service_ip     = try(network_profile.value.dns_service_ip, null)
      docker_bridge_cidr = try(network_profile.value.docker_bridge_cidr, null)
      outbound_type      = try(network_profile.value.outbound_type, null)
      pod_cidr           = try(network_profile.value.pod_cidr, null)
      service_cidr       = try(network_profile.value.service_cidr, null)
      load_balancer_sku  = try(network_profile.value.load_balancer_sku, null)
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = {
      for k, v in try(var.aks.auto_scaler_profile, {}) : k => v
    }

    content {
      balance_similar_node_groups      = try(auto_scaler_profile.value.balance_similar_node_groups, false)
      expander                         = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time       = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage           = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay           = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                    = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded              = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      empty_bulk_delete_max            = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      skip_nodes_with_local_storage    = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  default_node_pool {
    name       = "default"
    vm_size    = var.aks.default_node_pool.vmsize
    node_count = var.aks.default_node_pool.node_count
    max_count  = try(var.aks.default_node_pool.max_count, null)
    max_pods   = try(var.aks.default_node_pool.max_pods, 30)
    min_count  = try(var.aks.default_node_pool.min_count, null)
    zones      = try(var.aks.default_node_pool.zones, [])

    enable_auto_scaling          = try(var.aks.default_node_pool.auto_scaling, false)
    enable_host_encryption       = try(var.aks.default_node_pool.enable.host_encryption, false)
    enable_node_public_ip        = try(var.aks.default_node_pool.enable.node_public_ip, false)
    fips_enabled                 = try(var.aks.default_node_pool.enable.fips, null)
    only_critical_addons_enabled = try(var.aks.default_node_pool.enable.only_critical_addons, false)
    node_labels                  = try(var.aks.default_node_pool.node_labels, null)
    os_sku                       = try(var.aks.default_node_pool.os_sku, null)
    type                         = try(var.aks.default_node_pool.type, "VirtualMachineScaleSets")

    dynamic "upgrade_settings" {
      for_each = {
        for k, v in try(var.aks.node_pools.upgrade_settings, {}) : k => v
      }

      content {
        max_surge = upgrade_settings.value.default_node_pool.max_surge
      }
    }
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
    for pools in local.aks_pools : pools.pools_key => pools
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

  dynamic "upgrade_settings" {
    for_each = {
      for k, v in try(each.value.node_pools, {}) : k => v
    }

    content {
      max_surge = each.value.upgrade_settings.max_surge
    }
  }
}

#----------------------------------------------------------------------------------------
# role assignment
#----------------------------------------------------------------------------------------

resource "azurerm_role_assignment" "role" {
  for_each = var.aks.registry["attach"] ? { "attach" = true } : {}

  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.aks.registry.role_assignment_scope
  skip_service_principal_aad_check = true
}
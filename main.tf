# aks cluster
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

  dynamic "oms_agent" {
    for_each = try(var.aks.oms_agent, null) != null ? { "default" = var.aks.oms_agent } : {}

    content {
      log_analytics_workspace_id      = oms_agent.value.workspace_id
      msi_auth_for_monitoring_enabled = try(oms_agent.value.msi_auth_for_monitoring_enabled, false)
    }
  }

  dynamic "linux_profile" {
    for_each = try(var.aks.linux_profile, null) != null ? { "default" = var.aks.linux_profile } : {}

    content {
      admin_username = try(linux_profile.value.username, "nodeadmin")

      dynamic "ssh_key" {
        for_each = try(var.aks.linux_profile, null) != null ? { "default" = var.aks.linux_profile } : {}
        content {
          key_data = tls_private_key.tls[ssh_key.key].public_key_openssh
        }
      }
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
    workload_runtime             = try(var.aks.default_node_pool.workload_runtime, null)

    dynamic "upgrade_settings" {
      for_each = {
        for k, v in try(var.aks.node_pools.upgrade_settings, {}) : k => v
      }

      content {
        max_surge = upgrade_settings.value.default_node_pool.max_surge
      }
    }

    dynamic "linux_os_config" {
      for_each = length(try(var.aks.default_node_pool.config.linux_os, {})) > 0 ? { "default" = var.aks.default_node_pool.config.linux_os } : {}

      content {
        swap_file_size_mb = try(linux_os_config.value.swap_file_size_mb, null)
        dynamic "sysctl_config" {
          for_each = try(linux_os_config.value.sysctl_config, null) != null ? { "default" = linux_os_config.value.sysctl_config } : {}

          content {
            fs_aio_max_nr                      = try(sysctl_config.value.fs_aio_max_nr, null)
            fs_file_max                        = try(sysctl_config.value.fs_file_max, null)
            fs_inotify_max_user_watches        = try(sysctl_config.value.fs_inotify_max_user_watches, null)
            fs_nr_open                         = try(sysctl_config.value.fs_nr_open, null)
            kernel_threads_max                 = try(sysctl_config.value.kernel_threads_max, null)
            net_core_netdev_max_backlog        = try(sysctl_config.value.net_core_netdev_max_backlog, null)
            net_core_optmem_max                = try(sysctl_config.value.net_core_optmem_max, null)
            net_core_rmem_default              = try(sysctl_config.value.net_core_rmem_default, null)
            net_core_rmem_max                  = try(sysctl_config.value.net_core_rmem_max, null)
            net_core_somaxconn                 = try(sysctl_config.value.net_core_somaxconn, null)
            net_core_wmem_default              = try(sysctl_config.value.net_core_wmem_default, null)
            net_core_wmem_max                  = try(sysctl_config.value.net_core_wmem_max, null)
            net_ipv4_ip_local_port_range_max   = try(sysctl_config.value.net_ipv4_ip_local_port_range_max, null)
            net_ipv4_ip_local_port_range_min   = try(sysctl_config.value.net_ipv4_ip_local_port_range_min, null)
            net_ipv4_neigh_default_gc_thresh1  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh1, null)
            net_ipv4_neigh_default_gc_thresh2  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh2, null)
            net_ipv4_neigh_default_gc_thresh3  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh3, null)
            net_ipv4_tcp_fin_timeout           = try(sysctl_config.value.net_ipv4_tcp_fin_timeout, null)
            net_ipv4_tcp_keepalive_intvl       = try(sysctl_config.value.net_ipv4_tcp_keepalive_intvl, null)
            net_ipv4_tcp_keepalive_probes      = try(sysctl_config.value.net_ipv4_tcp_keepalive_probes, null)
            net_ipv4_tcp_keepalive_time        = try(sysctl_config.value.net_ipv4_tcp_keepalive_time, null)
            net_ipv4_tcp_max_syn_backlog       = try(sysctl_config.value.net_ipv4_tcp_max_syn_backlog, null)
            net_ipv4_tcp_max_tw_buckets        = try(sysctl_config.value.net_ipv4_tcp_max_tw_buckets, null)
            net_ipv4_tcp_tw_reuse              = try(sysctl_config.value.net_ipv4_tcp_tw_reuse, null)
            net_netfilter_nf_conntrack_buckets = try(sysctl_config.value.net_netfilter_nf_conntrack_buckets, null)
            net_netfilter_nf_conntrack_max     = try(sysctl_config.value.net_netfilter_nf_conntrack_max, null)
            vm_max_map_count                   = try(sysctl_config.value.vm_max_map_count, null)
            vm_swappiness                      = try(sysctl_config.value.vm_swappiness, null)
            vm_vfs_cache_pressure              = try(sysctl_config.value.vm_vfs_cache_pressure, null)
          }
        }
        transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
        transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
      }
    }

    dynamic "kubelet_config" {
      for_each = try(var.aks.default_node_pool.config.kubelet, null) != null ? { "default" = var.aks.default_node_pool.config.kubelet } : {}

      content {
        allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
        container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
        container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
        cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
        cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
        cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
        image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
        image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
        pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
        topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# node pools
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
  workload_runtime       = each.value.workload_runtime

  dynamic "upgrade_settings" {
    for_each = {
      for k, v in try(each.value.node_pools, {}) : k => v
    }

    content {
      max_surge = each.value.upgrade_settings.max_surge
    }
  }

  dynamic "linux_os_config" {
    for_each = {
      config = each.value.linux_os_config
    }

    content {
      swap_file_size_mb = try(linux_os_config.value.allowed_unsafe_sysctls, null)

      dynamic "sysctl_config" {
        for_each = try(linux_os_config.value.sysctl_config, null) != null ? { "default" = linux_os_config.value.sysctl_config } : {}
        content {
          fs_aio_max_nr                      = try(sysctl_config.value.fs_aio_max_nr, null)
          fs_file_max                        = try(sysctl_config.value.fs_file_max, null)
          fs_inotify_max_user_watches        = try(sysctl_config.value.fs_inotify_max_user_watches, null)
          fs_nr_open                         = try(sysctl_config.value.fs_nr_open, null)
          kernel_threads_max                 = try(sysctl_config.value.kernel_threads_max, null)
          net_core_netdev_max_backlog        = try(sysctl_config.value.net_core_netdev_max_backlog, null)
          net_core_optmem_max                = try(sysctl_config.value.net_core_optmem_max, null)
          net_core_rmem_default              = try(sysctl_config.value.net_core_rmem_default, null)
          net_core_rmem_max                  = try(sysctl_config.value.net_core_rmem_max, null)
          net_core_somaxconn                 = try(sysctl_config.value.net_core_somaxconn, null)
          net_core_wmem_default              = try(sysctl_config.value.net_core_wmem_default, null)
          net_core_wmem_max                  = try(sysctl_config.value.net_core_wmem_max, null)
          net_ipv4_ip_local_port_range_max   = try(sysctl_config.value.net_ipv4_ip_local_port_range_max, null)
          net_ipv4_ip_local_port_range_min   = try(sysctl_config.value.net_ipv4_ip_local_port_range_min, null)
          net_ipv4_neigh_default_gc_thresh1  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh1, null)
          net_ipv4_neigh_default_gc_thresh2  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh2, null)
          net_ipv4_neigh_default_gc_thresh3  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh3, null)
          net_ipv4_tcp_fin_timeout           = try(sysctl_config.value.net_ipv4_tcp_fin_timeout, null)
          net_ipv4_tcp_keepalive_intvl       = try(sysctl_config.value.net_ipv4_tcp_keepalive_intvl, null)
          net_ipv4_tcp_keepalive_probes      = try(sysctl_config.value.net_ipv4_tcp_keepalive_probes, null)
          net_ipv4_tcp_keepalive_time        = try(sysctl_config.value.net_ipv4_tcp_keepalive_time, null)
          net_ipv4_tcp_max_syn_backlog       = try(sysctl_config.value.net_ipv4_tcp_max_syn_backlog, null)
          net_ipv4_tcp_max_tw_buckets        = try(sysctl_config.value.net_ipv4_tcp_max_tw_buckets, null)
          net_ipv4_tcp_tw_reuse              = try(sysctl_config.value.net_ipv4_tcp_tw_reuse, null)
          net_netfilter_nf_conntrack_buckets = try(sysctl_config.value.net_netfilter_nf_conntrack_buckets, null)
          net_netfilter_nf_conntrack_max     = try(sysctl_config.value.net_netfilter_nf_conntrack_max, null)
          vm_max_map_count                   = try(sysctl_config.value.vm_max_map_count, null)
          vm_swappiness                      = try(sysctl_config.value.vm_swappiness, null)
          vm_vfs_cache_pressure              = try(sysctl_config.value.vm_vfs_cache_pressure, null)
        }
      }
      transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
      transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
    }
  }

  dynamic "kubelet_config" {
    for_each = {
      config = each.value.kubelet_config
    }

    content {
      allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
      container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
      container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
      cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
      cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
      cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
      image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
      image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
      pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
      topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
    }
  }
}

# tls key
resource "tls_private_key" "tls" {
  for_each = try(var.aks.linux_profile, null) != null ? { "default" = var.aks.linux_profile } : {}

  algorithm = try(each.value.algorithm, "RSA")
  rsa_bits  = try(each.value.rsa_bits, 4096)
}

# role assignment
resource "azurerm_role_assignment" "role" {
  for_each = try(var.aks.registry["attach"], false) ? { "attach" = true } : {}

  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.aks.registry.role_assignment_scope
  skip_service_principal_aad_check = true
}

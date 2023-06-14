provider "azurerm" {
  features {}
}

module "regions" {
  source = "github.com/aztfmods/module-azurerm-regions"

  workload    = var.workload
  environment = var.environment

  location = "westeurope"
}

module "rg" {
  source = "github.com/aztfmods/module-azurerm-rg"

  workload       = var.workload
  environment    = var.environment
  location_short = module.regions.location_short
  location       = module.regions.location
}

module "aks" {
  source = "../../"

  workload       = var.workload
  environment    = var.environment
  location_short = module.regions.location_short

  aks = {
    location            = module.rg.group.location
    resourcegroup       = module.rg.group.name
    node_resource_group = "${module.rg.group.name}-node"
    channel_upgrade     = "stable"
    dns_prefix          = "aksdemo"

    default_node_pool = {
      node_count = 1
      config = {
        linux_os = {
          sysctl_config = {
            fs_nr_open       = "1048576"
            vm_max_map_count = "242144"
          }
        }
        kubelet = {
          allowed_unsafe_sysctls = ["kernel.shm*", "kernel.msg*"]
          container_log_max_line = 100
          cpu_manager_policy     = "static"
        }
      }
      vmsize           = "Standard_DS2_v2"
      zones            = [1, 2, 3]
      workload_runtime = "OCIContainer"
    }

    node_pools = {
      pool1 = {
        vmsize     = "Standard_DS2_v2"
        node_count = 1
        max_surge  = 50
        config = {
          linux_os = {
            sysctl_config = {
              fs_nr_open        = "1048576"
              fs_aio_max_nr     = "1048576"
              net_core_wmem_max = "1048576"
              vm_max_map_count  = "242144"
            }
          }
          kubelet = {
            allowed_unsafe_sysctls = ["net.*.", "kernel.msg*"]
            container_log_max_line = 100
            cpu_manager_policy     = "static"
          }
        }
        workload_runtime = "OCIContainer"
      }
      pool2 = {
        vmsize     = "Standard_DS2_v2"
        node_count = 1
        max_surge  = 50
        config = {
          linux_os = {
            sysctl_config = {
              fs_nr_open    = "1048576"
              fs_aio_max_nr = "1048576"
            }
          }
        }
      }
    }
  }
  depends_on = [module.rg]
}


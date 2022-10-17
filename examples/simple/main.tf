provider "azurerm" {
  features {}
}

locals {
  naming = {
    company = "cn"
    env     = "p"
    region  = "weu"
  }
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"
  rgs = {
    aks = {
      name     = "rg-${local.naming.company}-aks-${local.naming.env}-${local.naming.region}"
      location = "westeurope"
    }
  }
}

module "aks" {
  source = "../../"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  aks = {
    demo = {
      location            = module.global.groups.aks.location
      resourcegroup       = module.global.groups.aks.name
      node_resource_group = "${module.global.groups.aks.name}-node"
      channel_upgrade     = "stable"

      sku        = "Free"
      dns_prefix = "aksdemo"
      version    = 1.22

      default_node_pool = {
        vmsize     = "Standard_DS2_v2"
        zones      = [1, 2, 3]
        node_count = 1
        max_count  = 10
        min_count  = 1

        enable = {
          auto_scaling = true
          azure_policy = true
        }
      }

      node_pools = {
        pool1 = {
          vmsize     = "Standard_DS2_v2"
          zones      = [1, 2, 3]
          node_count = 1
        }
      }
    }
  }
  depends_on = [module.global]
}
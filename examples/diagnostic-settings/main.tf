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

module "logging" {
  source = "github.com/aztfmods/module-azurerm-law"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  laws = {
    diags = {
      location      = module.global.groups.aks.location
      resourcegroup = module.global.groups.aks.name
      sku           = "PerGB2018"
      retention     = 30
    }
  }
  depends_on = [module.global]
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
      location      = module.global.groups.aks.location
      resourcegroup = module.global.groups.aks.name

      default_node_pool = {
        vmsize     = "Standard_DS2_v2"
        zones      = [1, 2, 3]
        node_count = 1
      }

      node_pools = {
        pool1 = { vmsize = "Standard_DS2_v2", count = 1 }
        pool2 = { vmsize = "Standard_DS2_v2", count = 1 }
      }
    }
  }
  depends_on = [module.global]
}

module "diagnostic_settings" {
  source = "github.com/aztfmods/module-azurerm-diags"
  count  = length(module.aks.merged_ids)

  resource_id           = element(module.aks.merged_ids, count.index)
  logs_destinations_ids = [lookup(module.logging.laws.diags, "id", null)]
}
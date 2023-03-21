provider "azurerm" {
  features {}
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"

  company = "cn"
  env     = "p"
  region  = "weu"

  rgs = {
    demo = { location = "westeurope" }
  }
}

module "analytics" {
  source = "github.com/aztfmods/module-azurerm-law"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  law = {
    location      = module.global.groups.demo.location
    resourcegroup = module.global.groups.demo.name
    sku           = "PerGB2018"
    retention     = 90
  }
  depends_on = [module.global]
}

module "aks" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  aks = {
    location            = module.global.groups.demo.location
    resourcegroup       = module.global.groups.demo.name
    node_resource_group = "${module.global.groups.demo.name}-node"

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      zones      = [1, 2, 3]
      node_count = 1
    }

    oms_agent = {
      workspace_id = module.analytics.law.id
    }
  }
  depends_on = [module.global]
}
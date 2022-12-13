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

module "aks" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  aks = {
    aks1 = {
      location            = module.global.groups.demo.location
      resourcegroup       = module.global.groups.demo.name
      node_resource_group = "${module.global.groups.demo.name}-node"

      default_node_pool = {
        vmsize     = "Standard_DS2_v2"
        node_count = 1
      }
    }

    aks2 = {
      location            = module.global.groups.demo.location
      resourcegroup       = module.global.groups.demo.name
      node_resource_group = "${module.global.groups.demo.name}-node"

      default_node_pool = {
        vmsize     = "Standard_DS2_v2"
        node_count = 1
      }
    }
  }
  depends_on = [module.global]
}
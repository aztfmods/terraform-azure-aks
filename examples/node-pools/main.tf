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
    demo = {
      location            = module.global.groups.demo.location
      resourcegroup       = module.global.groups.demo.name
      node_resource_group = "${module.global.groups.demo.name}-node"
      channel_upgrade     = "stable"
      dns_prefix          = "aksdemo"
      version             = 1.22

      default_node_pool = {
        vmsize           = "Standard_DS2_v2"
        zones            = [1, 2, 3]
        node_count       = 1

        upgrade_settings = {
          max_surge = 50
        }
      }

      node_pools = {
        pool1 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
        pool2 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
      }
    }
  }
  depends_on = [module.global]
}
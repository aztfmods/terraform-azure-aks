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

module "acr" {
  source = "github.com/aztfmods/module-azurerm-acr"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  registry = {
    location      = module.global.groups.demo.location
    resourcegroup = module.global.groups.demo.name
    sku           = "Premium"
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
    dns_prefix          = "demo"

    registry = {
      attach = true, role_assignment_scope = module.acr.acr.id
    }

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }
  }
  depends_on = [module.global]
}
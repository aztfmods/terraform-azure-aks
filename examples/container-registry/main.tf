provider "azurerm" {
  features {}
}

module "region" {
  source = "github.com/aztfmods/module-azurerm-regions"

  workload    = var.workload
  environment = var.environment

  location = "westeurope"
}

module "rg" {
  source = "github.com/aztfmods/module-azurerm-rg"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short
  location       = module.region.location
}

module "acr" {
  source = "github.com/aztfmods/module-azurerm-acr"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  registry = {
    location      = module.rg.group.location
    resourcegroup = module.rg.group.name
    sku           = "Premium"
  }
  depends_on = [module.rg]
}

module "aks" {
  source = "../../"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  aks = {
    location            = module.rg.group.location
    resourcegroup       = module.rg.group.name
    node_resource_group = "${module.rg.group.name}-node"
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

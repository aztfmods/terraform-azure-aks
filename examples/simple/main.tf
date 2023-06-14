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

module "kv" {
  source = "github.com/aztfmods/module-azurerm-kv"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  vault = {
    location      = module.rg.group.location
    resourcegroup = module.rg.group.name

    secrets = {
      tls_public_key = {
        aks = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }

    contacts = {
      admin = {
        email = "dummy@cloudnation.nl"
      }
    }
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

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      zones      = [1, 2, 3]
      node_count = 1
    }

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_key.aks.value
      }
    }
  }
  depends_on = [module.rg]
}

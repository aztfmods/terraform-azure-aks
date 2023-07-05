provider "azurerm" {
  features {}
}

module "rg" {
  source = "github.com/aztfmods/terraform-azure-rg?ref=v0.1.0"

  environment = var.environment

  groups = {
    demo = {
      region = "westeurope"
    }
  }
}

module "aks" {
  source = "github.com/aztfmods/terraform-azure-aks?ref=v1.14.0"

  workload    = var.workload
  environment = var.environment

  aks = {
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"
    channel_upgrade     = "stable"
    dns_prefix          = "aksdemo"

    default_node_pool = {
      node_count = 1
      vmsize           = "Standard_DS2_v2"
      zones            = [1, 2, 3]
    }

    node_pools = {
      pool1 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
      pool2 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
    }
  }
  depends_on = [module.rg]
}


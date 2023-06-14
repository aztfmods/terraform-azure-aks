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

module "analytics" {
  source = "github.com/aztfmods/module-azurerm-law"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  law = {
    location      = module.rg.group.location
    resourcegroup = module.rg.group.name
    sku           = "PerGB2018"
    retention     = 90
  }
  depends_on = [module.rg]
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

    enable = {
      public_access = true
    }

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      zones      = [1, 2, 3]
      node_count = 1
    }

    maintenance = {
      allowed = {
        w1 = {
          day   = "Saturday"
          hours = ["1", "6"]
        }
        w2 = {
          day   = "Sunday"
          hours = ["1"]
        }
      }
    }

    workspace = {
      id = module.analytics.law.id
      enable = {
        oms_agent = true
        defender  = true
      }
    }

    profile = {
      network = {
        plugin            = "azure"
        load_balancer_sku = "standard"
        load_balancer = {
          idle_timeout_in_minutes   = 30
          managed_outbound_ip_count = 10
        }
      }
      autoscaler = {
        enable = {
          keda         = true
          vertical_pod = true
        }
        linux = {
          username = "nodeadmin"
          ssh_key  = module.kv.tls_public_key.aks.value
        }
      }
    }
  }
  depends_on = [module.rg]
}

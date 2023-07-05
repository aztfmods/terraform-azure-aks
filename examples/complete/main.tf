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

module "analytics" {
  source = "github.com/aztfmods/terraform-azure-law?ref=v1.6.0"

  workload    = var.workload
  environment = var.environment

  law = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "PerGB2018"
    retention     = 90
  }
  depends_on = [module.rg]
}

module "kv" {
  source = "github.com/aztfmods/terraform-azure-kv?ref=v1.9.0"

  workload    = var.workload
  environment = var.environment

  vault = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

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
  source = "github.com/aztfmods/terraform-azure-aks?ref=v1.14.0"

  workload    = var.workload
  environment = var.environment

  aks = {
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"

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

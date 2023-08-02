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
}

module "aks" {
  #source = "github.com/aztfmods/terraform-azure-aks?ref=v1.16.0"
  source      = "../../"
  workload    = var.workload
  environment = var.environment

  aks = {
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }

    maintenance_auto_upgrade = {
      disallowed = {
        w1 = {
          start = "2023-08-02T15:04:05Z"
          end   = "2023-08-05T20:04:05Z"
        }
      }

      config = {
        frequency   = "RelativeMonthly"
        interval    = "2"
        duration    = "5"
        week_index  = "First"
        day_of_week = "Tuesday"
        start_time  = "00:00"
      }
    }

    maintenance_node_os = {
      disallowed = {
        w1 = {
          start = "2023-08-02T15:04:05Z"
          end   = "2023-08-05T20:04:05Z"
        }
      }

      config = {
        frequency   = "Weekly"
        interval    = "2"
        duration    = "5"
        day_of_week = "Monday"
        start_time  = "00:00"
      }
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

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_key.aks.value
      }
    }
  }
}

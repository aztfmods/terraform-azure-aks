![example workflow](https://github.com/aztfmods/module-azurerm-aks/actions/workflows/validate.yml/badge.svg)

# Kubernetes Service

Terraform module which creates kubernetes resources on Azure.

The below features are made available:

- multiple aks clusters
- multiple node pools on each cluster
- terratest is used to validate different integrations in [examples](examples)
- [diagnostic](examples/diagnostic-settings/main.tf) logs integration

The below examples shows the usage when consuming the module:

## Usage: single kubernetes cluster multiple node pools

```hcl
module "aks" {
  source = "github.com/dkooll/terraform-azurerm-aks"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  aks = {
    demo = {
      location      = module.global.groups.aks.location
      resourcegroup = module.global.groups.aks.name

      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        zones  = [1, 2, 3]
        count  = 2
      }

      node_pools = {
        pool1 = { vmsize = "Standard_DS2_v2", count = 1 }
        pool2 = { vmsize = "Standard_DS2_v2", count = 1 }
      }
    }
  }
  depends_on = [module.global]
}
```

## Usage: multiple kubernetes clusters

```hcl
module "aks" {
  source = "github.com/dkooll/terraform-azurerm-aks"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  aks = {
    aks1 = {
      location      = module.global.groups.aks.location
      resourcegroup = module.global.groups.aks.name

      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        count  = 1
      }
    }

    aks2 = {
      location      = module.global.groups.aks.location
      resourcegroup = module.global.groups.aks.name

      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        count  = 1
      }
    }
  }
}
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `aks` | describes aks related configuration | object | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `aks` | contains all bastion hosts |
| `merged_ids` | contains all resource id's specified within the object |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-aks/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-vnet/blob/main/LICENSE) for full details.
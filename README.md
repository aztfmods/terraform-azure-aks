# Kubernetes Service

This terraform module simplifies the creation and management of kubernetes resources on Azure, offering customizable options for cluster, node pool, network settings, and add-ons to ensure efficient deployment of kubernetes clusters.

The below features are made available:

- multiple aks clusters
- node pool support on each cluster
- terratest is used to validate different integrations
- diagnostic logs integration
- container registry integration

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
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

      default_node_pool = {
        vmsize     = "Standard_DS2_v2"
        zones      = [1, 2, 3]
        node_count = 1
      }
    }
  }
  depends_on = [module.global]
}
```

## Usage: node pools

```hcl
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
        vmsize     = "Standard_DS2_v2"
        zones      = [1, 2, 3]
        node_count = 1

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
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/1.39.0/docs/data-sources/resource_group) | datasource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `aks` | describes aks related configuration | object | yes |
| `company` | contains the company name used, for naming convention	| string | yes |
| `region` | contains the shortname of the region, used for naming convention	| string | yes |
| `env` | contains shortname of the environment used for naming convention	| string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `aks` | contains all bastion hosts |
| `merged_ids` | contains all resource id's specified within the module |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-aks/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-aks/blob/main/LICENSE) for full details.
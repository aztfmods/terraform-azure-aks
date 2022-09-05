![example workflow](https://github.com/dkooll/terraform-azurerm-aks/actions/workflows/validate.yml/badge.svg)

# Kubernetes Service

Terraform module which creates kubernetes resources on Azure.

The below features are made available:

- Multiple aks clusters
- Multiple node pools on each cluster
- Terratest is used to validate different integrations in [examples](examples)

The below examples shows the usage when consuming the module:

## Usage: single kubernetes cluster multiple node pools

```hcl
module "aks" {
  source = "github.com/dkooll/terraform-azurerm-aks"
  aks = {
    aks1 = {
      config = { location = "westeurope", resourcegroup = "rg-aks-weu" }
      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        count  = 1
      }

      node_pools = {
        pool1 = { vmsize = "Standard_DS2_v2", count = 1 }
        pool2 = { vmsize = "Standard_DS2_v2", count = 1 }
      }
    }
  }
}
```

## Usage: multiple kubernetes clusters

```hcl
module "aks" {
  source = "github.com/dkooll/terraform-azurerm-aks"
  aks = {
    aks1 = {
      config = { location = "westeurope", resourcegroup = "rg-aks-weu" }
      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        count  = 1
      }
    }

    aks2 = {
      config = { location = "eastus", resourcegroup = "rg-aks-eus" }
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
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `aks` | describes aks related configuration | object | yes |

## Outputs

| Name | Description |
| :-- | :-- |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/dkooll/terraform-azurerm-vnet/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/dkooll/terraform-azurerm-vnet/tree/master/LICENSE) for full details.
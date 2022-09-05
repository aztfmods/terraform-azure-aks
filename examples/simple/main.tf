module "aks" {
  source = "../../"
  aks = {
    aks1 = {
      config = { location = "westeurope", resourcegroup = "rg-aks-weu", zones = [1, 2, 3] }
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
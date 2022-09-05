module "aks" {
  source = "../../"
  aks = {
    aks1 = {
      config = { location = "westeurope", resourcegroup = "rg-aks-weu" }
      default_node_pool = {
        vmsize = "Standard_DS2_v2"
        count  = 1
      }
    }
  }
}
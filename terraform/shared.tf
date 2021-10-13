locals {
  azure_region = {
    short = "eus2"
    full  = "East US 2"
  }
  namespace = substr(lower(var.namespace), 0, 5)
}

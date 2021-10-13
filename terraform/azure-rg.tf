resource "azurerm_resource_group" "rg" {
  name     = format("%s-%s-rg", local.azure_region.short, local.namespace)
  location = local.azure_region.full
}

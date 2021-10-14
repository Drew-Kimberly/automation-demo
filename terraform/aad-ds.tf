data "azuread_client_config" "current" {}

resource "azurerm_subnet" "ds_subnet" {
  name                 = format("%s-ds-subnet", local.namespace)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/25"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = format("%s-nsg", local.namespace)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.ds_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azuread_group" "aad_dc_admins" {
  display_name     = "AAD DC Administrators"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_service_principal" "ds_spn" {
  application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
}

resource "azurerm_active_directory_domain_service" "aad_ds" {
  name                = format("%s-aad-ds", local.namespace)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  domain_name           = var.aad_domain_name
  sku                   = "Standard"
  filtered_sync_enabled = false

  initial_replica_set {
    subnet_id = azurerm_subnet.ds_subnet.id
  }

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  depends_on = [
    azuread_service_principal.ds_spn,
    azurerm_subnet_network_security_group_association.nsg_assoc,
  ]
}

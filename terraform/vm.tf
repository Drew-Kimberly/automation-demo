locals {
  admin_user        = "drewk"
  vm_public_ip_name = format("%s-vm-ip", local.namespace)
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = format("%s-vm-subnet", local.namespace)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = local.vm_public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                = format("%s-vm", local.namespace)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = format("%s-vm", local.namespace)
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_D2s_v3"
  admin_username                  = local.admin_user
  admin_password                  = "Pa55w0rd!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm_network_interface.id
  ]

  admin_ssh_key {
    username   = local.admin_user
    public_key = file(var.ssh_pub_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

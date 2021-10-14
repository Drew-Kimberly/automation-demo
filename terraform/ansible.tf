resource "local_file" "hosts_cfg" {
  content = templatefile("../ansible/templates/hosts.tpl",
    {
      ubuntu_vm_ip       = azurerm_public_ip.public_ip.ip_address
      admin_user         = local.admin_user
      autogen_disclaimer = "This file was automatically created during Terraform provisioning"
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}

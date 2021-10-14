data "azuread_client_config" "current" {}

resource "azuread_group" "vm_users" {
  display_name     = "VM Users"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "random_password" "berito_pw" {
  length = 16
}

resource "azuread_user" "berito" {
  user_principal_name = format("berito@%s", var.aad_domain_name)
  password            = random_password.berito_pw.result
  display_name        = "Ofelia Berit"
  given_name          = "Ofelia"
  surname             = "Berit"
}

resource "azuread_group" "vm_users" {
  display_name     = "VM Users"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "random_password" "berito_pw" {
  length = 16
}

output "berito_pw" {
  value     = random_password.berito_pw.result
  sensitive = true
}

resource "azuread_user" "berito" {
  user_principal_name = format("berito@%s", var.aad_domain_name)
  password            = random_password.berito_pw.result
  display_name        = "Ofelia Berit"
  given_name          = "Ofelia"
  surname             = "Berit"
}

resource "azuread_group_member" "berito_vm_users" {
  group_object_id  = azuread_group.vm_users.object_id
  member_object_id = azuread_user.berito.object_id
}

resource "local_file" "hosts_cfg" {
  content = templatefile("../ansible/templates/hosts.tpl",
    {
      ubuntu_vm_ip       = digitalocean_droplet.ubuntu_vm.ipv4_address
      autogen_disclaimer = "This file was automatically created during Terraform provisioning"
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}

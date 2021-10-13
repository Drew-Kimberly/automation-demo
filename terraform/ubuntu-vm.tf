resource "digitalocean_ssh_key" "ssh_key" {
  name       = format("%s SSH Key", local.namespace)
  public_key = file(var.ssh_pub_key_path)
}

resource "digitalocean_droplet" "ubuntu_vm" {
  image    = "ubuntu-20-04-x64"
  name     = format("%s-ubuntu-vm", local.namespace)
  region   = "nyc1"
  size     = "s-1vcpu-2gb"
  ssh_keys = [digitalocean_ssh_key.ssh_key.fingerprint]
}

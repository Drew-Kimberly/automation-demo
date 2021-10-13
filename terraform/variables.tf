variable "namespace" {
  description = "A name or namespace used to scope provisioned resource names"
  type        = string
}

variable "ssh_pub_key_path" {
  description = "Absolute path to your SSH public key"
  type        = string
}

variable "digitalocean_access_token" {
  description = "Access token for managing resources in DigitalOcean"
  type        = string
}

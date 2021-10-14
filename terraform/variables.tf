variable "namespace" {
  description = "A name or namespace used to scope provisioned resource names"
  type        = string
}

variable "ssh_pub_key_path" {
  description = "Absolute path to your SSH public key"
  type        = string
}

variable "aad_domain_name" {
  description = "The domain of the AAD tenant used to create the AAD Domain Services"
  type        = string
}

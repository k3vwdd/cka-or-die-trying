variable "kube_server_farm" {
  description = "A map of my kubernetes server farm (debian-12-amd64-20251112-2294-prod-s2fy2g55okxhk)"
  type = map(object({
    instance_type = string
    root_block_device = object({
      volume_size           = number
      volume_type           = string
      delete_on_termination = bool
      encrypted             = bool
    })
    subnet_id           = string
    security_group_type = string
    user_data_type      = string
    tags                = map(string)
  }))
}

variable "allowed_ssh_cidr" {
  description = "Allowed ssh ip list"
  type        = list(string)
}

variable "ssh_public_key" {
  description = "user should provide there public key content ~/.ssh/id_rsa.pub"
  type        = string
}

variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "The Azure region where resources will be deployed"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of labels to apply to contained resources."
}

variable "admin_username" {
  type        = string
  description = "Temporary administrator username for Ubuntu VM"
}

variable "admin_password" {
  type        = string
  description = "Temporary administrator password for Ubuntu VM"
}

variable "admin_public_ssh_key" {
  type        = string
  description = "The public key that the admin will use to SSH into the machine"
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network to be created."
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["172.20.0.0/16"]
  description = "The address space that is used by the virtual network."
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet within the virtual network."
}

variable "subnet_address_prefixes" {
  type        = list(string)
  default     = ["172.20.0.0/24"]
  description = "The address prefix to use for the subnet."
}

variable "nsg_name" {
  type        = string
  description = "The name of the network security group to be created."
}

variable "resource_group_name" {
  type        = string
  description = "The Azure Resource Group that this resource will be created in."
}

variable "location" {
  type        = string
  default     = "East US"
  description = "The Azure region where resources will be deployed"
}

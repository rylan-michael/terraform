terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.93"
    }
  }
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "main" {
    name = var.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "main" {
  name               = var.nsg_name
  location           = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the network security group to the subnet
resource "azurerm_subnet_network_security_group_association" "main" {
    subnet_id = azurerm_subnet.main.id
    network_security_group_id = azurerm_network_security_group.main.id
}
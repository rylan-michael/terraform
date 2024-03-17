provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rylan_mccarty-${var.name}"
  location = "East US"

  tags = var.tags
}

module "networking" {
  source                  = "../../modules/networking"
  vnet_name               = "${var.name}-vnet"
  vnet_address_space      = ["172.20.0.0/16"]
  subnet_name             = "${var.name}-subnet"
  subnet_address_prefixes = ["172.20.0.0/24"]
  nsg_name                = "${var.name}-nsg"
  resource_group_name     = azurerm_resource_group.main.name
}

resource "azurerm_public_ip" "main" {
  name                = "${var.name}-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_public_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "2000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}

# `Dynamic` Public IP addresses aren't allocated until they're attached to a device.
data "azurerm_public_ip" "main" {
  name                = azurerm_public_ip.main.name
  resource_group_name = azurerm_linux_virtual_machine.main.resource_group_name
}

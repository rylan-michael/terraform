provider "azurerm" {
  features {}
}

variable "vm_name" {
  description = "VM name and prefix for supporting infrastructure."
  default     = "winvm"
}

variable "admin_username" {
  description = "Temporary administrator usermae for Windows VM"
  type        = string
}

variable "admin_password" {
  description = "Temporary administrator password for Windows VM"
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "rg" {
  name     = "rylan_mccarty-${var.vm_name}"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["172.20.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  address_prefixes     = ["172.20.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.vm_name}-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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


resource "azurerm_windows_virtual_machine" "winvm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-hotpatch"
    version   = "latest"
  }

  computer_name            = var.vm_name
  enable_automatic_updates = true
  patch_mode = "AutomaticByPlatform"
  provision_vm_agent       = true
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "auto_shutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.winvm.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "2000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}

# resource "azurerm_virtual_machine_extension" "openssh" {
#   name                 = "WindowsOpenSSH"
#   virtual_machine_id   = azurerm_windows_virtual_machine.winvm.id
#   publisher            = "Microsoft.Azure.OpenSSH"
#   type                 = "OpenSSH"
#   type_handler_version = "3.0"
# }

# Associate the network security group to the subnet
resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# `Dynamic` Public IP addresses aren't allocated until they're attached to a device
# (e.g., a VM). Instead you can obtain the IP Address once the Public IP has been assigned via
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.ip.name
  resource_group_name = azurerm_windows_virtual_machine.winvm.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}


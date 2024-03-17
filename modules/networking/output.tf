output "virtual_network_id" {
    value = azurerm_virtual_network.main.id
    description = "The unique identifier of the virtual network created."
}

output "virtual_network_name" {
    value = azurerm_virtual_network.main.id
    description = "The name of the virtual network created."
}

output "subnet_id" {
    value = azurerm_subnet.main.id
    description = "The unique identifier of the subnet created within the virtual network."
}

output "subnet_name" {
    value = azurerm_subnet.main.name
    description = "The name of the subnet created within the virtual network."
}

output "network_security_group_id" {
    value = azurerm_network_security_group.main.id
    description = "The unique identifier of the network security group created."
}

output "network_security_group_name" {
    value = azurerm_network_security_group.main.name
    description = "The name of the network security group created to managed access to the subnet resources."
}

output "subnet_network_security_group_association_id" {
    value = azurerm_network_security_group.main.id
    description = "The association ID between the subnet and the network security group."
}
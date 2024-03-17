output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "public_ip_address" {
  value       = data.azurerm_public_ip.main.ip_address
  description = "IP Address for the virtual machine"
}

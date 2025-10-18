output "vnet_id" { value = azurerm_virtual_network.main.id }
output "subnet_app_id" { value = azurerm_subnet.app.id }
output "subnet_pe_id" { value = azurerm_subnet.pe.id }
output "nsg_app_id" { value = azurerm_network_security_group.nsg_app.id }

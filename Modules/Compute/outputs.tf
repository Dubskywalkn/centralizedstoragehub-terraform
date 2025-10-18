# VM1 public IP (null if not created)
output "vm1_public_ip" { value = try(azurerm_public_ip.pubip1[0].ip_address, null)}

# VM2 public IP (null if not created / disabled)
output "vm2_public_ip" { value = try(azurerm_public_ip.pubip2[0].ip_address, null)}

# Managed Identity principal IDs (for RBAC module)
output "vm1_principal_id" { value = azurerm_linux_virtual_machine.vm1_ledgerlock.identity[0].principal_id}
output "vm2_principal_id" { value = try(azurerm_linux_virtual_machine.vm2_ledgerlock[0].identity[0].principal_id, null)}

# VM IDs (handy for references)
output "vm1_id" { value = azurerm_linux_virtual_machine.vm1_ledgerlock.id }
output "vm2_id" { value = try(azurerm_linux_virtual_machine.vm2_ledgerlock[0].id, null) }

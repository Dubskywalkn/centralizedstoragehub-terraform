# Recovery Services Vault (stores VM backups)
resource "azurerm_recovery_services_vault" "vault" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = "Standard"
  storage_mode_type = "GeoRedundant" 
  public_network_access_enabled = false 
}

# Daily backup policy
resource "azurerm_backup_policy_vm" "daily" {
  name                = "vm-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 8
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 6
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

# Protect VM1
resource "azurerm_backup_protected_vm" "vm1" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.vm1_id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}

# Protect VM2 only if provided (null check)
resource "azurerm_backup_protected_vm" "vm2" {
  count               = var.enable_standby_vm ? 1 : 0
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.vm2_id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}

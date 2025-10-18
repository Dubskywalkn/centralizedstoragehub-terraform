resource "azurerm_storage_account" "storage" {
  resource_group_name      = var.resource_group_name
  location                 = var.location
  name                     = "stledgerlock"
  account_tier             = "Standard"
  account_replication_type = "GZRS"

  public_network_access_enabled    = false
  allow_nested_items_to_be_public  = false
  min_tls_version                  = "TLS1_2"
  cross_tenant_replication_enabled = false


  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content { days = 7 }
    }
    dynamic "container_delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content { days = 7 }
    }
    versioning_enabled = var.enable_versioning
  }
}






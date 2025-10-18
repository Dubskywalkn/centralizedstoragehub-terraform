data "azurerm_client_config" "current" {}

locals {
  scopes_by_container = {
    for name in var.container_names :
    name => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.storage_account_name}/blobServices/default/containers/${name}"
  }
}

resource "azurerm_role_assignment" "assign" {
  for_each             = local.scopes_by_container
  scope                = each.value
  role_definition_name = var.role_name
  principal_id         = var.principal_id
}

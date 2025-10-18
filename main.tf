resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "Compute" {
  source                 = "./Modules/Compute"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  app_subnet_id          = module.Network.subnet_app_id
  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_ssh_public_key   = var.admin_ssh_public_key
  os_image               = var.os_image
  disk_size              = var.disk_size
  assign_public_ip       = var.assign_public_ip
  enable_standby_vm      = var.enable_standby_vm
  enable_availabilty_set = true
  availabilty_set_name   = "as-ledgerlock"
}

module "Network" {
  source                    = "./Modules/Network"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  vnet_name                 = var.vnet_name
  vnet_cidr                 = var.vnet_cidr
  app_subnet                = var.app_subnet
  app_subnet_cidr           = var.app_subnet_cidr
  pe_subnet                 = var.pe_subnet
  pe_subnet_cidr            = var.pe_subnet_cidr
  ssh_source_address_prefix = var.ssh_source_address_prefix
}

module "Storage" {
  source               = "./Modules/Storage"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  storage_account_name = var.storage_account_name
  enable_soft_delete   = var.enable_soft_delete
  enable_versioning    = var.enable_versioning
}

module "RBAC_vm1" {
  source               = "./Modules/RBAC"
  principal_id         = module.Compute.vm1_principal_id
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_name = module.Storage.storage_account_name
  container_names      = var.blob_containers
}

module "RBAC_vm2" {
  source               = "./Modules/RBAC"
  principal_id         = module.Compute.vm2_principal_id
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_name = module.Storage.storage_account_name
  container_names      = var.blob_containers
}

module "PE" {
  source              = "./Modules/PrivateEndpoint"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  pe_subnet_id        = module.Network.subnet_pe_id
  vnet_id_for_dns     = module.Network.vnet_id
  storage_account_id  = module.Storage.storage_account_id
}

module "Backup" {
  source              = "./Modules/Backup"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  vault_name        = "bkv-ledgerlock"
  vm1_id            = module.Compute.vm1_id
  vm2_id            = module.Compute.vm2_id 
  enable_standby_vm = var.enable_standby_vm
}

# Public IPs
resource "azurerm_public_ip" "pubip1" {
  count               = var.assign_public_ip ? 1 : 0
  name                = "pubip-vm1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pubip2" {
  count               = (var.assign_public_ip && var.enable_standby_vm) ? 1 : 0
  name                = "pubip-vm2"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#NICs
resource "azurerm_network_interface" "nic1" {
  name                = "nic-vm1"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.pubip1[0].id : null
  }
}

resource "azurerm_network_interface" "nic2" {
  count               = var.enable_standby_vm ? 1 : 0
  name                = "nic-vm2"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.pubip2[0].id : null
  }
}

# Availabilty Set
resource "azurerm_availability_set" "as" {
  count               = var.enable_availabilty_set ? 1 : 0
  name                = var.availabilty_set_name
  resource_group_name = var.resource_group_name
  location            = var.location

  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

#VM 1
resource "azurerm_linux_virtual_machine" "vm1_ledgerlock" {
  name                  = "vm1-ledgerlock"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic1.id]
  availability_set_id   = var.enable_availabilty_set ? azurerm_availability_set.as[0].id : null
  identity {
    type = "SystemAssigned"
  }
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  os_disk {
    name                 = "osdisk-vm1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }
}

# VM 2 Standby
resource "azurerm_linux_virtual_machine" "vm2_ledgerlock" {
  count                 = var.enable_standby_vm ? 1 : 0
  name                  = "vm2-ledgerlock"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic2[count.index].id]
  availability_set_id   = var.enable_availabilty_set ? azurerm_availability_set.as[0].id : null
  identity {
    type = "SystemAssigned"
  }
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  os_disk {
    name                 = "osdisk-vm2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }
}


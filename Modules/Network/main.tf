# Virtual network
resource "azurerm_virtual_network" "main" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
}

# App subnet
resource "azurerm_subnet" "app" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  name                 = var.app_subnet
  address_prefixes     = [var.app_subnet_cidr]
}

# Private endpoint subnet
resource "azurerm_subnet" "pe" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  name                 = var.pe_subnet
  address_prefixes     = [var.pe_subnet_cidr]
}

# NSG
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-${var.app_subnet}"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "Allow-SSHToMyIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# NSG associating with app subnet
resource "azurerm_subnet_network_security_group_association" "name" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}


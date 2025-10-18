variable "resource_group_name" {
  description = "The name of the azure resource group"
  type        = string
  default     = "rg-ledgerlock"
}

variable "location" {
  description = "The region for the azure resources"
  type        = string
  default     = "eastus"
}

variable "admin_username" {
  description = "The username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key_username" {
  description = "Username for SSH key"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-ledgerlock"
}

variable "vnet_cidr" {
  description = "CIDR for the VNET"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet" {
  description = "The name for the app subnet"
  type        = string
  default     = "app-subnet"
}

variable "app_subnet_cidr" {
  description = "CIDR for the app subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pe_subnet" {
  description = "The name of the private endpoint subnet"
  type        = string
  default     = "pe-subnet"
}

variable "pe_subnet_cidr" {
  description = "CIDR for the pe subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_ssh_public_key" {
  description = "Public SSH key for admin access"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B2s"
}

variable "os_image" {
  description = "The image for the Ubuntu Server"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "disk_size" {
  description = "Size of the disk for the VM"
  type        = number
  default     = 30
}

variable "assign_public_ip" {
  description = "Public IP for the VM"
  type        = bool
  default     = true
}

variable "enable_standby_vm" {
  description = "Create a second VM for cold standby"
  type        = bool
  default     = true
}

variable "create_private_endpoint" {
  description = "Private Endpoint for my Storage account"
  type        = bool
  default     = true
}

variable "create_dns_zone" {
  description = "dns zone for pe"
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "The name for the storage account"
  type        = string
  default     = "stledgerlock"
}

variable "enable_soft_delete" {
  description = "enabling soft delete"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "enabling versioning"
  type        = bool
  default     = true
}

variable "blob_containers" {
  type    = set(string)
  default = ["qbo", "stripe", "drive", "email", "published"]
}

variable "ssh_source_address_prefix" {
  description = "The source IP address or CIDR range allowed for SSH access."
  type        = string
  default     = "203.0.113.10/32"
}


variable "enable" {
  description = "Create assignments"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Built-in or custom role name"
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    project    = "finops"
    enviroment = "prod"
    owner      = "ITOps"
  }
}
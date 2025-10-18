variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "admin_username" { type = string } 
variable "admin_ssh_public_key" { type = string }
variable "vm_size" { type = string }
variable "os_image" { type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })}
variable "disk_size" { type = number }
variable "assign_public_ip" { type = bool }
variable "enable_standby_vm" { type = bool }
variable "app_subnet_id" { type = string }
variable "enable_availabilty_set" { type = bool }
variable "availabilty_set_name" { type = string }
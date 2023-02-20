#create resource group
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    enviroment = "dev"
  }
}

#create virtual network
resource "azurerm_virtual_network" "network" {
  name                = "virtual-network"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.123.0.0/16"]
  tags = {
    enviroment = "dev"
  }
}
#create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.123.1.0/24"]
  

}
#create nsg. Allow all vm in the same subnet access, restrict access from internet
resource "azurerm_network_security_group" "nsg" {
  name                = "network-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags = {
    enviroment = "dev"
  }
}
#security rule
resource "azurerm_network_security_rule" "sec-rule" {
  for_each                    = local.nsgrules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  
}
resource "azurerm_subnet_network_security_group_association" "group_assiosiation" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}
#create public ip
resource "azurerm_public_ip" "public_ip" {
  name                = "TestPublicIP"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"

  tags = {
    enviroment = "dev"
  }
}
#create network interface
resource "azurerm_network_interface" "nic" {
  count= var.number_of_VM
  name                = "nic-${count.index+1}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal-${count.index+1}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    //public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags = {
    enviroment = "dev"
  }
}

#Create loadbalancer
resource "azurerm_lb" "lb" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  tags = {
    enviroment = "dev"
  }
}
#backend address pool
resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
  

}
#address pool assosiation
resource "azurerm_network_interface_backend_address_pool_association" "adP" {
  count=var.number_of_VM
  network_interface_id    = azurerm_network_interface.nic[count.index].id 
  ip_configuration_name   = "internal-${count.index+1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
  
}
#create virtual machine availibiity set
resource "azurerm_availability_set" "availibility_Set" {
  name                = "aset"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  
  tags = {
    enviroment = "dev"
  }
}
#get packer resource group
data "azurerm_resource_group" "image" {
  name = var.packer_resource_group_name
}
#get packer image
data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

#create managed disk
resource "azurerm_managed_disk" "mDisk" {
  count=var.number_of_VM
  name                 = "disk-${count.index+1}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.resource_group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
  tags = {
    enviroment = "dev"
  }
}

#create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  count=var.number_of_VM
  name                = "VM-${count.index+1}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_F2"
  source_image_id = data.azurerm_image.image.id
  admin_username = var.admin_user
  admin_password = var.admin_password
  disable_password_authentication = false
  availability_set_id=azurerm_availability_set.availibility_Set.id
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  tags = {
    enviroment = "dev"
  }
  

  os_disk {
    name="OsDisk${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 }

 resource "azurerm_virtual_machine_data_disk_attachment" "diskAttachemet" {
  count=var.number_of_VM
  managed_disk_id    = azurerm_managed_disk.mDisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
  lun                ="10"
  caching            = "ReadWrite"
  
}

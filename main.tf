# resource "azurerm_resource_group" "name" {
#   name = "ashish"
#   location = "eastus"
# }

resource "azurerm_resource_group" "rg-b" {
 name= "todo1"
location  = "japan east"
}

resource "azurerm_virtual_network" "vnet-b" {
  name                = "todo-vnet"
  location            = azurerm_resource_group.rg-b.location
  resource_group_name = azurerm_resource_group.rg-b.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-b" {
  name = "frontend-subnet"
  resource_group_name =  azurerm_resource_group.rg-b.name
  virtual_network_name = azurerm_virtual_network.vnet-b.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic-b" {
  name                = "frontend-nic"
  location            = azurerm_resource_group.rg-b.location
  resource_group_name = azurerm_resource_group.rg-b.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-b.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg-b" {
  name                = "frontend-nsg"
  location            = azurerm_virtual_network.vnet-b.location
  resource_group_name = azurerm_resource_group.rg-b.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine" "vm-b" {
  name                = "frontend-machine"
  resource_group_name = azurerm_resource_group.rg-b.name
  location            = azurerm_virtual_network.vnet-b.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Password@12345678"
  network_interface_ids = [
    azurerm_network_interface.nic-b.id,
  ]

 disable_password_authentication = "false"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nsg" {
  network_interface_id      = azurerm_network_interface.nic-b.id
  network_security_group_id = azurerm_network_security_group.nsg-b.id
}
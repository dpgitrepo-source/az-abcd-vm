locals {
  location = "Canada Central"
  name = "abcd"

  app_subnet = [for s in azurerm_subnet.app-subnet : s if startswith(s.name, "app")][0]

}

resource "azurerm_resource_group" "vm-rg" {
  name     = "${local.name}-rg"
  location = local.location
}

resource "azurerm_virtual_network" "mini-network" {
  name                = "${local.name}-network"
  address_space       = var.vnet-range
  location            = local.location
  resource_group_name = azurerm_resource_group.vm-rg.name
}

resource "azurerm_subnet" "app-subnet" {
  for_each = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.vm-rg.name
  virtual_network_name = azurerm_virtual_network.mini-network.name
  address_prefixes     = each.value.address_range
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app-subnet["app-subnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vmip.id
  }

  lifecycle{
    create_before_destroy = true
  } 
}

resource "azurerm_public_ip" "vmip" {
  name                = "publicipforvm"
  resource_group_name = azurerm_resource_group.vm-rg.name
  location            = local.location
  allocation_method   = "Static"

  lifecycle{
    create_before_destroy = true
  } 
}

resource "azurerm_network_security_group" "nsg-vm" {
  name                = "nsgforvm"
  location            = local.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  dynamic security_rule {
  
    for_each = var.nsg-security-rules
    content {
    name                       = security_rule.value.name
    priority                   = security_rule.value.priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = security_rule.value.destination_port_range
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg-atatched-tosubnet" {
  subnet_id                 = azurerm_subnet.app-subnet[local.app_subnet.name].id
  network_security_group_id = azurerm_network_security_group.nsg-vm.id
}

resource "azurerm_linux_virtual_machine" "vm-app" {
  name                = "vm-app"
  resource_group_name = azurerm_resource_group.vm-rg.name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/passwd.pub")
  }

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


output "app-subnet" {
  value = local.app_subnet
  
}
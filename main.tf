resource "azurerm_resource_group" "rg" {
  name = "uklab-rg"
  location = "centralus"
}

resource "azurerm_virtual_network" "myvnet" {
  name = "my-vnet"
  address_space = ["10.0.0.0/16"]
  location = "centralus"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "frontendsubnet" {
  name = "frontendSubnet"
  resource_group_name =  azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "windows-vm-nsg" {
  name                = "windows-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowWINRM"
    description                = "Allow WINRM"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "windows-vm-nsg-association" {
  subnet_id                 = azurerm_subnet.frontendsubnet.id
  network_security_group_id = azurerm_network_security_group.windows-vm-nsg.id
}

resource "azurerm_public_ip" "myvm1publicip" {
  name = "pubip1"
  location = "centralus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "myvm1nic" {
  name = "myvm1-nic"
  location = "centralus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myvm1publicip.id
  }
}

resource "azurerm_windows_virtual_machine" "terravm1" {
  name                  = "terravm1"  
  location              = "centralus"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  size                  = "Standard_D2ads_v5"
  admin_username        = "adminuser"
  admin_password        = "Anime.12"

 source_image_reference {
   publisher = "MicrosoftWindowsDesktop"
   offer     = "Windows-10"
   sku       = "win10-21h2-avd"
   version   = "latest"
}

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
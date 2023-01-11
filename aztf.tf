variable "subscription_id" {
  default = "12345678-1234-1234-1234-1234567891"
}

variable "ventureName" {
  default = "12345678-1234-1234-1234-1234567891"
}

variable "tenant_id" {
  default = "12345678-1234-1234-1234-1234567891"
}


provider "azurerm" {
    use_msi         = true
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    features {}
}

#### Add your terraform below

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_ssh_public_key" "example" {
  name                = "example"
  resource_group_name = "example"
  location            = "West Europe"
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz8m1oseIPAs+N+l2VND/0j4G9W48tEjfJCcU0iIIlb8EUtyVlJUw4u3sp9SWtQfVmt2A0E9KGnUwFl6a4m+kK7A+hrtmXd6aDEZ+e1/kQBmkHabM/AJ7pP4AKge9es0Rc0HPjG+3YE14sJGXOJWrPBK6t5p5Vitzg7cFzdyCuvb51HCY1GSnRD1X6f855Mk6CGx+zPM5djyA2NHJ5poKULA406h1jrSlOA3zqPw06Rr13m+s0U5PTNvD7uSWmF6OGbW/J2MPCCtB5A8/mbnRy0Dgia3P8xImtvANgL6N0Uutkq6uxeH2vUZAGDmYB8T+luB8Ev7w7+SNNEWBNtHuudUX2Kf3nSoatwfZXMGFFp/AkzwkoHN8iV+5OY1dagu2ldiiZO9y0dGxtagCcRKztGGVO904a3gSsto77O6sekeadgdW+Y4KrbFcEUnuaB6ShsQ/866pBei3x12UVYoLNGcEtz0jymJ8lHCLO7f6b8irpH/juRPjWRvJUGACtoZ0="
}

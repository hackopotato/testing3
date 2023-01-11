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

# create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
    name = "sometestrg"
    location = "ukwest"
}

# create virtual network
resource "azurerm_virtual_network" "vnet" {
    name = "tfvnet"
    address_space = ["10.0.0.0/16"]
    location = "ukwest"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

# create subnet
resource "azurerm_subnet" "subnet" {
    name = "tfsub"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "10.0.2.0/24"
    #network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

# create public IPs
resource "azurerm_public_ip" "ip" {
    name = "tfip"
    location = "ukwest"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    public_ip_address_allocation = "dynamic"
    domain_name_label = "sometestdn"

    tags {
        environment = "staging"
    }
}

# create network interface
resource "azurerm_network_interface" "ni" {
    name = "tfni"
    location = "ukwest"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "ipconfiguration"
        subnet_id = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.0.2.5"
        public_ip_address_id = "${azurerm_public_ip.ip.id}"
    }
}

# create storage account
resource "azurerm_storage_account" "storage" {
    name = "someteststorage"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "ukwest"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

# create storage container
resource "azurerm_storage_container" "storagecont" {
   

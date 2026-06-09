resource "azurerm_resource_group" "eschool" {
    name = "${var.name_prefix}-rg"
    location = var.location
}

resource "azurerm_virtual_network" "eschool" {
    name = "${var.name_prefix}-virtual-network"
    resource_group_name = azurerm_resource_group.eschool.name
    location = azurerm_resource_group.eschool.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "eschool" {
    name = "${var.name_prefix}-subnet"
    resource_group_name = azurerm_resource_group.eschool.name
    virtual_network_name = azurerm_virtual_network.eschool.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "eschool" {
    name = "${var.name_prefix}-network-sg"
    resource_group_name = azurerm_resource_group.eschool.name
    location = azurerm_resource_group.eschool.location

    security_rule {
        name                       = "allow-ssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

resource "azurerm_public_ip" "eschool" {
    count = var.vm_count
    name = "${var.name_prefix}-vm${count.index + 1}-publicip"
    resource_group_name = azurerm_resource_group.eschool.name
    location = azurerm_resource_group.eschool.location
    allocation_method = "Static"
   
}

resource "azurerm_network_interface" "eschool" {
    count = var.vm_count
    name = "${var.name_prefix}-vm${count.index + 1}-network-ic"
    resource_group_name = azurerm_resource_group.eschool.name
    location = azurerm_resource_group.eschool.location

    ip_configuration {
        name = "${var.name_prefix}-vm${count.index + 1}-ip-config"
        subnet_id = azurerm_subnet.eschool.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.eschool[count.index].id
    }
}

resource "azurerm_network_interface_security_group_association" "eschool" {
    count = var.vm_count
    network_interface_id = azurerm_network_interface.eschool[count.index].id
    network_security_group_id = azurerm_network_security_group.eschool.id
}


resource "azurerm_linux_virtual_machine" "vm" {
    count = var.vm_count
    name = "${var.name_prefix}-vm${count.index + 1}"
    resource_group_name = azurerm_resource_group.eschool.name
    location = azurerm_resource_group.eschool.location
    size = var.vm_size
    admin_username = var.admin_username
    network_interface_ids = [azurerm_network_interface.eschool[count.index].id]

    admin_ssh_key {
        username = var.admin_username
        public_key = file(pathexpand(var.ssh_public_key_path))
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
}
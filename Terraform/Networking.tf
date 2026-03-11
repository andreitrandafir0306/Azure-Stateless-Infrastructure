# Create a virtual network within the resource group

resource "azurerm_virtual_network" "this" {
  name                = "asi-network"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}

# Create a subnet 

resource "azurerm_subnet" "this" {
  name                 = "asi-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.123.2.0/24"]
}

# Create a network security group

resource "azurerm_network_security_group" "this" {
  name                = "asi-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}

# Create NSG rule to allow SSH only from master node to managed notes

resource "azurerm_network_security_rule" "secondary-rule" {
  name                        = "managed-nodes-access"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "${resource.azurerm_linux_virtual_machine.control-node.private_ip_address}/32"
  destination_address_prefix  = resource.azurerm_subnet.this.address_prefixes[0]
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Associate NSG with Subnet

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Create public IP address for control node 

resource "azurerm_public_ip" "this" {
  name                = "ControlNodePublicIP"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}

# Create NIC for master node

resource "azurerm_network_interface" "this" {
  name                = "Public-NIC"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}

# Create NICs for managed nodes

resource "azurerm_network_interface" "managed-nic" {
  count               = 3
  name                = "Private-NIC-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}




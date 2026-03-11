# Create data source for the NIC's public IP to automatically establish SSH connection

data "azurerm_public_ip" "this" {
  name                = azurerm_public_ip.this.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create data source for resource group

data "azurerm_resource_group" "rg" {
  name = var.rg
}

# Create data source for control node NIC private IP address to add in NSG rule

data "azurerm_network_interface" "this" {
  name                = azurerm_network_interface.this.name
  resource_group_name = data.azurerm_resource_group.rg.name
}
# Create data source for the NIC's public IP to automatically establish SSH connection

data "azurerm_public_ip" "this" {
  name                = azurerm_public_ip.this.name
  resource_group_name = azurerm_resource_group.asi-group.name
}

data "azurerm_resource_group" "rg" {
  name = var.rg
}
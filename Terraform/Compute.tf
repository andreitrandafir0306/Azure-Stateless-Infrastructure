# Create Master Node VM

resource "azurerm_linux_virtual_machine" "control-node" {
  name                  = "ansible-tower"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = "Standard_DC1ds_v3"
  admin_username        = "ansible-tower"
  network_interface_ids = [azurerm_network_interface.this.id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "ansible-tower"
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202601300"
  }


  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
  }
}

# Create managed nodes VMs

resource "azurerm_linux_virtual_machine" "managed-node" {
  count                 = 3
  name                  = "managed-node-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = "Standard_DC1ds_v3"
  admin_username        = "managed-node"
  network_interface_ids = [azurerm_network_interface.managed-nic[count.index].id]

  admin_ssh_key {
    username   = "managed-node"
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202601300"
  }


  tags = {
    environment = "test"
    project     = "azure-stateless-infra"
    role        = "managed-node"
  }
}

# Assign role to Master Node in order to read data from the private NICs and from the VMs

resource "azurerm_role_assignment" "managed-nics" {
  count                = length(azurerm_network_interface.managed-nic)
  scope                = azurerm_network_interface.managed-nic[count.index].id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.control-node.identity[0].principal_id
}

resource "azurerm_role_assignment" "managed-vms" {
  count                = length(azurerm_linux_virtual_machine.managed-node)
  scope                = azurerm_linux_virtual_machine.managed-node[count.index].id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.control-node.identity[0].principal_id
}


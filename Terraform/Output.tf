output "control_node_ip" {
  value       = data.azurerm_public_ip.this.ip_address
  description = "Public IP of the Control Node"
  sensitive   = true
}

output "control_node_prv_ip" {
  value       = data.azurerm_network_interface.this.private_ip_address
  description = "Private IP of the Control Node"
  sensitive   = true
}
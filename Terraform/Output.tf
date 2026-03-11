output "control_node_ip" {
  value       = data.azurerm_public_ip.this.ip_address
  description = "Public IP of the Master VM"
  sensitive   = true
}
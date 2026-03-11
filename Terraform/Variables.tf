# Define public key 

variable "public_key" {
  type      = string
  sensitive = true
}

# Define resource group 

variable "rg" {
  type      = string
}

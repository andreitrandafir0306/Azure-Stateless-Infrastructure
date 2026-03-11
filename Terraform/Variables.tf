
# Define trusted source IP as local PC for master node access

variable "source_ip" {
  type = string
}

# Define public key 

variable "public_key" {
  type      = string
  sensitive = true
}

# Define resource group 

variable "rg" {
  type      = string
}

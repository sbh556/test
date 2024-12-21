variable "resource_group" {
  type = string
  default = "Daniel-Candidate"
}

variable "Region" {
  type = string
  default = "westeurope"
}

variable "Vm_username" {
  type = string
  default = "Daniel"
}

variable "vm_password" {
  type = string
  sensitive = true
  default = "123QWEasd"
}

variable "ngnix_namespace" {
  type = string
  default = "nginx-namespace"
}

variable "ttl" {
  type = number
  default = 3600
}

variable "securityRules" {
  type = list(object({
    name = string
    protocol = string
    source_port_range = string
    destination_port_range =string
    access = string
    priority = number
    direction = string
    source_address_prefix = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "allowHTTP-Inbound"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol = "*"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allowHTTPs-Inbound"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol = "*"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allowSSH-Inbound"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol = "*"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
        {
      name                       = "allowJenkins-Inbound"
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol = "*"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
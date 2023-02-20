locals {
  nsgrules = {

    subnet_inbound = {
      name                       = "subnet_in"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.123.0.0/24"
      destination_address_prefix = "10.123.0.0/24"
    }

    subnet_outbound = {
      name                       = "subnet_out"
      priority                   = 101
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.123.0.0/24"
      destination_address_prefix = "10.123.0.0/24"
    }

    deny_list_in = {
      name                       = "deny_list_in"
      priority                   = 201
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    deny_list_out = {
      name                       = "deny_list_out"
      priority                   = 202
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

}
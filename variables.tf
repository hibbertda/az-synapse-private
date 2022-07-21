variable "environment" {
  type = string
  default = "public"
}

variable "location" {
  type = string
  default = "centralus"
}

variable "virtualNetwork" {
  description = "Virtual network configuration"
  default = {
    address_space = ["10.0.0.0/16"]
  }
}

variable "subnets" {
  description = "Subnets"
  default = [
    {
        name = "priv-synapse"
        address_prefix = ["10.0.2.0/24"]
    },
    {
        name = "vm"
        address_prefix = ["10.0.3.0/24"]
    },
    {
        name = "AzureBastionSubnet"
        address_prefix = ["10.0.4.0/26"]
    }
  ]
}
variable "synapsePrivateEndpoints" {
	type = set(string)
  description = "Private endpoints for accessing synapse features"
  default = [
    "sql",
    "dev",
    "sqlondemand"
  ]
}
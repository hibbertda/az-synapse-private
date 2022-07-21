resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-pl-synapse"
  location            = var.resourcegroup.location
  resource_group_name = var.resourcegroup.name
  address_space       = var.virtualnetwork["address_space"]
}

resource "azurerm_subnet" "subnets" {
    depends_on = [
      azurerm_virtual_network.vnet
    ]
	for_each = {
		for index, subnet in var.subnets:
		subnet.name => subnet
	}
  name                  = each.value.name  
  resource_group_name   = var.resourcegroup.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = each.value.address_prefix 

  enforce_private_link_endpoint_network_policies = false
}
resource "azurerm_public_ip" "baspip" {
  name                = "bas7d9pip"
  location            = var.resourcegroup.location
  resource_group_name = var.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = "bastion"
  location            = var.resourcegroup.location
  resource_group_name = var.resourcegroup.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.baspip.id
  }
}
# For testing - use the current account for assigning permissions
data "azurerm_client_config" "currentuser" {}

# All resources deployed to a single resource group
resource "azurerm_resource_group" "rg-priv-synapse" {
  name     = "rg-synapse-private"
  #location = "centralus"
  location = var.location
}

# Deploy required network resources
module "network" {
  source = "./modules/network"
  resourcegroup = azurerm_resource_group.rg-priv-synapse
  virtualnetwork = var.virtualNetwork
  subnets = var.subnets
}

# DNS Zones
module "dns" {
  source = "./modules/dns"
  resourcegroup = azurerm_resource_group.rg-priv-synapse
  virtualnetwork = module.network.vnet
}

# Synapse
module "private-synapse" {
  source = "./modules/synapse"
  resourcegroup = azurerm_resource_group.rg-priv-synapse
}

# Private Link(Endpoint) setup [This is the hard part]
module "private-link" {
  source                  = "./modules/privatelink"
  resourcegroup           = azurerm_resource_group.rg-priv-synapse
  virtualnetwork          = module.network.vnet
  subnet                  = module.network.subnets["priv-synapse"]
  #DNS
  pldns                   = module.dns.pldns
  syndns                  = module.dns.syndns
  #Synapse
  synhublink              = module.private-synapse.synhublink
  synwrksc                = module.private-synapse.synwrksc
  synapsePrivateEndpoints = var.synapsePrivateEndpoints
}

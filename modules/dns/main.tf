/*
DNS is the linch pin of private link. To enable a private Azure Synapse
workspace there are two private zones required. 

    - privatelink.azuresynapse.net [A]
    - azuresynapse.net [CNAME]

Both are required to enable a client to connect to the workspace using
the private endpoint. 

Having both zones linked to a virtual network will result in failures
attempting to access a publicy available Synapse workspace. It is possible
to use a third-party DNS system with conditional rules to modify this behavior
but that is out of scope for this example. 
*/

# Create Private DNS Zones
resource "azurerm_private_dns_zone" "synPrivLinkDNS" {
  name                = var.plDnsDomain
  resource_group_name = var.resourcegroup.name
}

resource "azurerm_private_dns_zone" "synDNS" {
  name                = var.dnsDomain
  resource_group_name = var.resourcegroup.name
}

# Link private dns zones to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "pldnslink" {
  name                  = "pldnslink"
  depends_on = [
    azurerm_private_dns_zone.synPrivLinkDNS
  ]
  resource_group_name   = var.resourcegroup.name
  private_dns_zone_name = azurerm_private_dns_zone.synPrivLinkDNS.name
  virtual_network_id    = var.virtualnetwork.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  name                  = "dnslink"
  depends_on = [
    azurerm_private_dns_zone.synDNS
  ]
  resource_group_name   = var.resourcegroup.name
  private_dns_zone_name = azurerm_private_dns_zone.synDNS.name
  virtual_network_id    = var.virtualnetwork.id
}
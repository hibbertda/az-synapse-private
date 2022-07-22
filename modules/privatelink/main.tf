resource "azurerm_private_endpoint" "synPrivateHub" {
  /*
  Private Endpoint to Synapse Private Hub. This configuration is seperate from other
  synapse private endpoints representing the different interfaces. 
  */
  name = "synHubPL"
  resource_group_name = var.resourcegroup.name
  location            = var.resourcegroup.location
  subnet_id           = var.subnet.id

  private_service_connection {
    name = "synHubPL"
    is_manual_connection = false
    private_connection_resource_id = var.synhublink.id
    subresource_names = ["web"]
  }

  private_dns_zone_group {
    #name                  = "www"
    name                  = var.environment == "public" ? "www" : "web"
    private_dns_zone_ids  = [
      var.pldns.id
    ]
  }
}

resource "azurerm_private_endpoint" "synwkspcEndpoints" {
  /*
  loop through the three synapse workspace interfaces [dev | sql | sqlondemand]
  and create a priavte link to the vnet for each.
  */
	for_each            = var.synapsePrivateEndpoints
  name                = "syn${each.value}"
  resource_group_name = var.resourcegroup.name
  location            = var.resourcegroup.location
  subnet_id           = var.subnet.id

  private_service_connection {
    name                            = "syn${each.value}"
    is_manual_connection            = false
    private_connection_resource_id  = var.synwrksc.id
    subresource_names               = [each.value]
  }

  private_dns_zone_group {
    name                  = each.value
    private_dns_zone_ids  = [
      var.pldns.id
    ]
  }
}

resource "azurerm_private_dns_cname_record" "syncnameprivatename" {
  # CNAME record for the Synapse Private hub link
  name                = azurerm_private_endpoint.synPrivateHub.private_dns_zone_group[0].name
  zone_name           = var.syndns.name
  resource_group_name = var.resourcegroup.name
  ttl                 = 300
  record              = "${azurerm_private_endpoint.synPrivateHub.private_dns_zone_group[0].name}.privatelink.azuresynapse.net"
}

resource "azurerm_private_dns_cname_record" "syncname" {
  /*
  Create the required DNS CNAME records in the private '.azuresynapse.net' domain.
  The host names are composed on the synapse instance name, and the interface type,
  but can be different from just the interface type. The correct fqdn is read 

  Don't know if this is right, but hey it works!
  */ 
 	for_each = {
		for index, group in azurerm_private_endpoint.synwkspcEndpoints:
		group.name => group
	} 

  name                = each.value.private_dns_zone_configs[0].record_sets[0].name
  zone_name           = var.syndns.name
  resource_group_name = var.resourcegroup.name
  ttl                 = 300
  record              = each.value.private_dns_zone_configs[0].record_sets[0].fqdn
}



output "privateEnd" {
  value = azurerm_private_endpoint.synwkspcEndpoints
}

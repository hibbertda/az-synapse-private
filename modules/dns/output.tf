output "pldns" {
  value = azurerm_private_dns_zone.synPrivLinkDNS
}

output "syndns" {
  value = azurerm_private_dns_zone.synDNS
}
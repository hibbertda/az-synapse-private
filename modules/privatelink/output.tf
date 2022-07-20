output "privateEndpoints" {
  value = azurerm_private_endpoint.synwkspcEndpoints
}

output "privateEndpoint_hub" {
  value = azurerm_private_endpoint.synPrivateHub
}
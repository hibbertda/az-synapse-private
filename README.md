# TEMPLATE - Private Synapse Workspace

[![Azure Public](https://github.com/hibbertda/az-synapse-private/actions/workflows/tf-deploy.yml/badge.svg?branch=main)](https://github.com/hibbertda/az-synapse-private/actions/workflows/tf-deploy.yml)

Template for deploying a private Azure Synapse Workspace. Utilizing Azure Private Endpoints to enable access directly from a private VNet.

## Deployment Network Concessions

When the Synapse Workspace is set to disabled the built-agent/runner will need to have direct network access to the private endpoints to continue configuring the workspace. Could be possible to leave the workspace public access enabled while configuration in progress, then set to disabled at the end.

There is a firewall rule added in the Synapse module that allows connections to the public endpoints from any source. The rule can be modified to be more restrictive if the source is known. This is intended only for initial deployment. Azure Synapse firewall rules are not evaluated when public access is disbled.

```yaml
resource "azurerm_synapse_firewall_rule" "prvsyn-fw" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.prvsyn-wkspc.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
```

# Generate password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
data "azurerm_client_config" "currentuser" {}

resource "azurerm_storage_account" "sasynprv" {
  name                      = "examp5d36q7rbest"
  location                  = var.resourcegroup.location
  resource_group_name       = var.resourcegroup.name
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  is_hns_enabled            = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "sasynprv-adls" {
  name               = "prvsynadls"
  storage_account_id = azurerm_storage_account.sasynprv.id
}

resource "azurerm_synapse_workspace" "prvsyn-wkspc" {
  name                                  = "prvsyn-5d34le"
  location                              = var.resourcegroup.location
  resource_group_name                   = var.resourcegroup.name
  storage_data_lake_gen2_filesystem_id  = azurerm_storage_data_lake_gen2_filesystem.sasynprv-adls.id
  sql_administrator_login               = "sqladminuser"
  sql_administrator_login_password      = random_password.password.result

  managed_virtual_network_enabled       = true
	linking_allowed_for_aad_tenant_ids    = [
		data.azurerm_client_config.currentuser.tenant_id
	]
	public_network_access_enabled         = true

  aad_admin {
    login     = data.azurerm_client_config.currentuser.client_id
    object_id = data.azurerm_client_config.currentuser.object_id
    tenant_id = data.azurerm_client_config.currentuser.tenant_id
  }
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_synapse_firewall_rule" "prvsyn-fw" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.prvsyn-wkspc.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

resource "azurerm_synapse_private_link_hub" "prvsyn-link-hub" {
  name                  = "prvsynlink"
  location              = var.resourcegroup.location
  resource_group_name   = var.resourcegroup.name
}
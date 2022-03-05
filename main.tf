data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name

}

data "azurerm_storage_account" "sa" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_data_factory" "df" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "dl" {
  name                  = "LS_SA_${var.storage_account_name}"
  resource_group_name   = var.resource_group_name
  data_factory_id       = azurerm_data_factory.df.id
  use_managed_identity  = true
  tenant                = data.azurerm_client_config.current.tenant_id
  url                   = data.azurerm_storage_account.sa.primary_dfs_endpoint
}

resource "azurerm_data_factory_linked_service_key_vault" "ls_kv" {
  name                = "LS_KV_${var.key_vault_name}"
  resource_group_name = var.resource_group_name
  data_factory_id     = azurerm_data_factory.df.id
  key_vault_id        = data.azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_access_policy" "df_to_kv" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_data_factory.identity[0].object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_role_assignment" "example" {
  scope                = data.storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.identity[0].object_id
}
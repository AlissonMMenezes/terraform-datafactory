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
  tenant                = "8abcf116-35fa-47ac-90ff-0d9db900a1a4"
  url                   = data.azurerm_storage_account.sa.primary_dfs_endpoint
}

resource "azurerm_data_factory_linked_service_key_vault" "ls_kv" {
  name                = "LS_KV_${var.key_vault_name}"
  resource_group_name = var.resource_group_name
  data_factory_id     = azurerm_data_factory.df.id
  key_vault_id        = data.azurerm_key_vault.kv.id
}


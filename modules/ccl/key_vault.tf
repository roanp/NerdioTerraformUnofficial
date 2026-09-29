resource "azurerm_key_vault" "ccl_key_vault" {
  name                = var.ccl_key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  enabled_for_deployment     = false
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  rbac_authorization_enabled = true

  public_network_access_enabled = var.configure_private_endpoints ? false : true

  network_acls {
    bypass         = "AzureServices"
    default_action = var.configure_private_endpoints ? "Deny" : "Allow"
  }

  tags = merge(
    {
      NMW_OBJECT_TYPE = "PAAS"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.KeyVault/vaults",
      {}
    )
  )
}

# Allow the deploying principal to manage secrets, keys, and certificates (data plane)
# for manual/future configuration.
resource "azurerm_role_assignment" "ccl_key_vault_deployer_secrets_officer" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "ccl_key_vault_deployer_crypto_officer" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "ccl_key_vault_deployer_certificates_officer" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Allow the CCL Web App's managed identity to read secrets, keys, and certificates (data plane).
resource "azurerm_role_assignment" "ccl_key_vault_app_secrets_officer" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_windows_web_app.ccl_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "ccl_key_vault_app_crypto_user" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_windows_web_app.ccl_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "ccl_key_vault_app_certificate_user" {
  scope                = azurerm_key_vault.ccl_key_vault.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_windows_web_app.ccl_app.identity[0].principal_id
}

resource "azurerm_private_endpoint" "ccl_key_vault" {
  count               = var.configure_private_endpoints ? 1 : 0
  name                = "${var.ccl_key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id
  tags                = lookup(var.tags_by_resource, "Microsoft.Network/privateEndpoints", {})

  private_service_connection {
    name                           = "${var.ccl_key_vault_name}-pls"
    private_connection_resource_id = azurerm_key_vault.ccl_key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.key_vault_private_dns_zone_id]
  }
}

resource "azurerm_management_lock" "ccl_key_vault_lock" {
  count      = var.protect_resources ? 1 : 0
  name       = "${var.ccl_key_vault_name}-lock"
  scope      = azurerm_key_vault.ccl_key_vault.id
  lock_level = "CanNotDelete"
  notes      = "KeyVault should not be deleted."
}

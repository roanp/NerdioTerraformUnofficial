# Captures the moment this storage account is first created and keeps that value
# stable across future applies (unlike timestamp(), which changes on every plan).
resource "time_static" "custom_scripts_storage_created" {}

# Normally auto-created by NME during the first VM deployment (to hold custom
# scripts used for session host customization). Pre-creating it here with the same
# tags NME looks for lets it find and reuse this one instead of creating its own.
resource "azurerm_storage_account" "custom_scripts" {
  name                = var.custom_scripts_storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = local.storage_replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = true
  https_traffic_only_enabled       = true

  public_network_access_enabled = var.configure_private_endpoints ? false : true

  infrastructure_encryption_enabled = false

  network_rules {
    default_action = var.configure_private_endpoints ? "Deny" : "Allow"
    bypass         = ["AzureServices"]
  }

  # NMW_OBJECT_TYPE and NMW_CREATED_DATE are how NME identifies this storage account —
  # placed last so they can never be silently overridden by tags_by_resource.
  tags = merge(
    lookup(var.tags_by_resource, "Microsoft.Storage/storageAccounts", {}),
    {
      NMW_OBJECT_TYPE  = "CUSTOM_SCRIPTS_STORAGE_ACCOUNT"
      NMW_CREATED_DATE = time_static.custom_scripts_storage_created.rfc3339
    }
  )
}

resource "azurerm_private_endpoint" "custom_scripts_storage_blob" {
  count               = var.configure_private_endpoints ? 1 : 0
  name                = "${azurerm_storage_account.custom_scripts.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.private_endpoints_subnet_id
  tags                = lookup(var.tags_by_resource, "Microsoft.Network/privateEndpoints", {})

  private_service_connection {
    name                           = "${var.custom_scripts_storage_account_name}-blob-pls"
    private_connection_resource_id = azurerm_storage_account.custom_scripts.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.blob_private_dns_zone_id]
  }
}

resource "azurerm_management_lock" "custom_scripts_storage_lock" {
  count      = var.protect_resources ? 1 : 0
  name       = "${var.custom_scripts_storage_account_name}-lock"
  scope      = azurerm_storage_account.custom_scripts.id
  lock_level = "CanNotDelete"
  notes      = "StorageAccount should not be deleted."
}

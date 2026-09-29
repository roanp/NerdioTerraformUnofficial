resource "azurerm_storage_account" "rti_storage" {
  name                = var.rti_storage_account_name
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

  tags = lookup(
    var.tags_by_resource,
    "Microsoft.Storage/storageAccounts",
    {}
  )
}

resource "azurerm_private_endpoint" "rti_storage_blob" {
  count               = var.configure_private_endpoints ? 1 : 0
  name                = "${var.rti_storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id
  tags                = lookup(var.tags_by_resource, "Microsoft.Network/privateEndpoints", {})

  private_service_connection {
    name                           = "${var.rti_storage_account_name}-blob-pls"
    private_connection_resource_id = azurerm_storage_account.rti_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.blob_private_dns_zone_id]
  }
}

resource "azurerm_management_lock" "rti_storage_lock" {
  count      = var.protect_resources ? 1 : 0
  name       = "${var.rti_storage_account_name}-lock"
  scope      = azurerm_storage_account.rti_storage.id
  lock_level = "CanNotDelete"
  notes      = "StorageAccount should not be deleted."
}

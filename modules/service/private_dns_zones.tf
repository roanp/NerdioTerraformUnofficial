# Looked up only when private_dns_zone_resource_group_name is set, i.e. the private
# DNS zones are pre-existing and externally managed (e.g. a centrally-shared DNS hub).
# This module never creates, modifies, or deletes these zones in that case — it only
# reads their IDs so it can link its own VNet and attach private endpoints to them.

data "azurerm_private_dns_zone" "key_vault" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.key_vault_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "blob" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.blob_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "table" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.table_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "app_service" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.app_service_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "sql" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.sql_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "automation" {
  count               = var.configure_private_endpoints && local.use_existing_private_dns_zones ? 1 : 0
  name                = local.automation_private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

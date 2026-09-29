terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}

resource "azurerm_resource_group" "core" {
  name     = var.resource_group_name
  location = var.location
}

module "service" {
  source = "../modules/service"

  resource_group_name = azurerm_resource_group.core.name

  azuread_app_name                      = var.azuread_app_name
  disable_implicit_grant_token_issuance = var.disable_implicit_grant_token_issuance
  azure_environment                     = var.azure_environment
  subscription_display_name             = var.subscription_display_name

  location          = azurerm_resource_group.core.location
  protect_resources = var.protect_resources

  # (keep passing through the rest as you already do)
  azure_tag_prefix                     = var.azure_tag_prefix
  app_service_plan_sku_name            = var.app_service_plan_sku_name
  sql_collation                        = var.sql_collation
  database_max_size_gb                 = var.database_max_size_gb
  database_sku_name                    = var.database_sku_name
  tags_by_resource                     = var.tags_by_resource
  configure_private_endpoints          = var.configure_private_endpoints
  deployment_vnet_name                 = var.deployment_vnet_name
  deployment_resource_group_name       = var.deployment_resource_group_name
  network_config                       = var.network_config
  private_web_app                      = var.private_web_app
  web_app_portal_name                  = var.web_app_portal_name
  app_service_plan_name                = var.app_service_plan_name
  sql_server_name                      = var.sql_server_name
  database_name                        = var.database_name
  key_vault_name                       = var.key_vault_name
  app_insights_name                    = var.app_insights_name
  automation_account_name              = var.automation_account_name
  law_name                             = var.law_name
  logs_law_name                        = var.logs_law_name
  scripted_action_account_name         = var.scripted_action_account_name
  data_protection_storage_account_name = var.data_protection_storage_account_name
  data_protection_keys_blob_name       = var.data_protection_keys_blob_name
  data_protection_key_name             = var.data_protection_key_name
  maintenance_service_url              = var.maintenance_service_url
  app_package_version                  = var.app_package_version
  app_package_local_path               = var.app_package_local_path
  app_role_assignments                 = var.app_role_assignments
  private_endpoint_post_resolve_delay  = var.private_endpoint_post_resolve_delay
  app_cert_name                        = var.app_cert_name
  app_cert_lifetime_months             = var.app_cert_lifetime_months
}

module "ccl" {
  count  = var.deploy_ccl_module ? 1 : 0
  source = "../modules/ccl"

  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location

  protect_resources = var.protect_resources
  tags_by_resource  = var.tags_by_resource

  ccl_app_name = var.ccl_app_name

  use_existing_app_service_plan = var.ccl_use_existing_app_service_plan
  existing_app_service_plan_id  = module.service.app_service_plan_id
  ccl_app_service_plan_name     = var.ccl_app_service_plan_name
  ccl_app_service_plan_sku_name = var.ccl_app_service_plan_sku_name
  ccl_key_vault_name            = var.ccl_key_vault_name
  ccl_storage_account_name      = var.ccl_storage_account_name
  ccl_law_name                  = var.ccl_law_name
  ccl_app_insights_name         = var.ccl_app_insights_name

  # Reuses the private endpoints network already created by modules/service —
  # module.service is always created, so its (possibly-null) outputs are always available.
  configure_private_endpoints     = var.configure_private_endpoints
  private_ccl_app                 = var.private_ccl_app
  private_endpoints_subnet_id     = module.service.private_endpoints_subnet_id
  app_subnet_id                   = module.service.app_subnet_id
  key_vault_private_dns_zone_id   = module.service.key_vault_private_dns_zone_id
  blob_private_dns_zone_id        = module.service.blob_private_dns_zone_id
  app_service_private_dns_zone_id = module.service.app_service_private_dns_zone_id
}

module "rti" {
  count  = var.deploy_rti_module ? 1 : 0
  source = "../modules/rti"

  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  azure_environment   = var.azure_environment

  protect_resources = var.protect_resources
  tags_by_resource  = var.tags_by_resource

  # The existing NME app's service principal — granted a SQL user in the RTI
  # database so Nerdio Manager itself can connect to it.
  nme_service_principal_name = var.azuread_app_name

  rti_app_name                  = var.rti_app_name
  rti_app_service_plan_name     = var.rti_app_service_plan_name
  rti_app_service_plan_sku_name = var.rti_app_service_plan_sku_name
  rti_key_vault_name            = var.rti_key_vault_name
  rti_storage_account_name      = var.rti_storage_account_name
  rti_law_name                  = var.rti_law_name
  rti_app_insights_name         = var.rti_app_insights_name
  rti_sql_server_name           = var.rti_sql_server_name
  rti_database_name             = var.rti_database_name
  rti_sql_collation             = var.rti_sql_collation
  rti_database_max_size_gb      = var.rti_database_max_size_gb
  rti_database_sku_name         = var.rti_database_sku_name

  private_rti_app = var.private_rti_app

  # Reuses the private endpoints network already created by modules/service —
  # module.service is always created, so its (possibly-null) outputs are always available.
  configure_private_endpoints         = var.configure_private_endpoints
  private_endpoint_post_resolve_delay = var.private_endpoint_post_resolve_delay
  private_endpoints_subnet_id         = module.service.private_endpoints_subnet_id
  app_subnet_id                       = module.service.app_subnet_id
  key_vault_private_dns_zone_id       = module.service.key_vault_private_dns_zone_id
  blob_private_dns_zone_id            = module.service.blob_private_dns_zone_id
  app_service_private_dns_zone_id     = module.service.app_service_private_dns_zone_id
  sql_private_dns_zone_id             = module.service.sql_private_dns_zone_id
}

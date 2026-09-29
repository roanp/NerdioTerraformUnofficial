# Web App outputs
output "ccl_app_id" {
  description = "The ID of the CCL Windows Web App"
  value       = azurerm_windows_web_app.ccl_app.id
}

output "ccl_app_name" {
  description = "The name of the CCL Windows Web App"
  value       = azurerm_windows_web_app.ccl_app.name
}

output "ccl_app_default_hostname" {
  description = "The default hostname of the CCL Windows Web App"
  value       = azurerm_windows_web_app.ccl_app.default_hostname
}

output "ccl_app_identity_principal_id" {
  description = "The Principal ID of the CCL Web App's managed identity"
  value       = azurerm_windows_web_app.ccl_app.identity[0].principal_id
}

output "ccl_app_identity_tenant_id" {
  description = "The Tenant ID of the CCL Web App's managed identity"
  value       = azurerm_windows_web_app.ccl_app.identity[0].tenant_id
}

# App Service Plan outputs
output "ccl_app_service_plan_id" {
  description = "The ID of the App Service Plan the CCL Web App runs on (existing or dedicated)"
  value       = local.ccl_service_plan_id
}

output "ccl_app_service_plan_name" {
  description = "The name of the dedicated CCL App Service Plan (null when use_existing_app_service_plan = true)"
  value       = var.use_existing_app_service_plan ? null : azurerm_service_plan.ccl_app_service_plan[0].name
}

# Key Vault outputs
output "ccl_key_vault_id" {
  description = "The ID of the CCL Key Vault"
  value       = azurerm_key_vault.ccl_key_vault.id
}

output "ccl_key_vault_name" {
  description = "The name of the CCL Key Vault"
  value       = azurerm_key_vault.ccl_key_vault.name
}

output "ccl_key_vault_uri" {
  description = "The URI of the CCL Key Vault"
  value       = azurerm_key_vault.ccl_key_vault.vault_uri
}

# Storage Account outputs
output "ccl_storage_account_id" {
  description = "The ID of the CCL Storage Account"
  value       = azurerm_storage_account.ccl_storage.id
}

output "ccl_storage_account_name" {
  description = "The name of the CCL Storage Account"
  value       = azurerm_storage_account.ccl_storage.name
}

output "ccl_storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the CCL Storage Account"
  value       = azurerm_storage_account.ccl_storage.primary_blob_endpoint
}

# Log Analytics Workspace outputs
output "ccl_law_id" {
  description = "The ID of the CCL Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.ccl_law.id
}

output "ccl_law_name" {
  description = "The name of the CCL Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.ccl_law.name
}

output "ccl_law_workspace_id" {
  description = "The Workspace ID of the CCL Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.ccl_law.workspace_id
}

# Application Insights outputs
output "ccl_app_insights_id" {
  description = "The ID of the CCL Application Insights"
  value       = azurerm_application_insights.ccl_app_insights.id
}

output "ccl_app_insights_name" {
  description = "The name of the CCL Application Insights"
  value       = azurerm_application_insights.ccl_app_insights.name
}

output "ccl_app_insights_connection_string" {
  description = "The connection string of the CCL Application Insights"
  value       = azurerm_application_insights.ccl_app_insights.connection_string
  sensitive   = true
}

output "ccl_app_insights_instrumentation_key" {
  description = "The instrumentation key of the CCL Application Insights"
  value       = azurerm_application_insights.ccl_app_insights.instrumentation_key
  sensitive   = true
}

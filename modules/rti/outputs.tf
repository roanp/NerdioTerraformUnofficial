# Web App outputs
output "rti_app_id" {
  description = "The ID of the RTI Windows Web App"
  value       = azurerm_windows_web_app.rti_app.id
}

output "rti_app_name" {
  description = "The name of the RTI Windows Web App"
  value       = azurerm_windows_web_app.rti_app.name
}

output "rti_app_default_hostname" {
  description = "The default hostname of the RTI Windows Web App"
  value       = azurerm_windows_web_app.rti_app.default_hostname
}

output "rti_app_identity_principal_id" {
  description = "The Principal ID of the RTI Web App's managed identity"
  value       = azurerm_windows_web_app.rti_app.identity[0].principal_id
}

output "rti_app_identity_tenant_id" {
  description = "The Tenant ID of the RTI Web App's managed identity"
  value       = azurerm_windows_web_app.rti_app.identity[0].tenant_id
}

# App Service Plan outputs
output "rti_app_service_plan_id" {
  description = "The ID of the RTI App Service Plan"
  value       = azurerm_service_plan.rti_app_service_plan.id
}

output "rti_app_service_plan_name" {
  description = "The name of the RTI App Service Plan"
  value       = azurerm_service_plan.rti_app_service_plan.name
}

# Key Vault outputs
output "rti_key_vault_id" {
  description = "The ID of the RTI Key Vault"
  value       = azurerm_key_vault.rti_key_vault.id
}

output "rti_key_vault_name" {
  description = "The name of the RTI Key Vault"
  value       = azurerm_key_vault.rti_key_vault.name
}

output "rti_key_vault_uri" {
  description = "The URI of the RTI Key Vault"
  value       = azurerm_key_vault.rti_key_vault.vault_uri
}

# Storage Account outputs
output "rti_storage_account_id" {
  description = "The ID of the RTI Storage Account"
  value       = azurerm_storage_account.rti_storage.id
}

output "rti_storage_account_name" {
  description = "The name of the RTI Storage Account"
  value       = azurerm_storage_account.rti_storage.name
}

output "rti_storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the RTI Storage Account"
  value       = azurerm_storage_account.rti_storage.primary_blob_endpoint
}

# Log Analytics Workspace outputs
output "rti_law_id" {
  description = "The ID of the RTI Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.rti_law.id
}

output "rti_law_name" {
  description = "The name of the RTI Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.rti_law.name
}

output "rti_law_workspace_id" {
  description = "The Workspace ID of the RTI Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.rti_law.workspace_id
}

# Application Insights outputs
output "rti_app_insights_id" {
  description = "The ID of the RTI Application Insights"
  value       = azurerm_application_insights.rti_app_insights.id
}

output "rti_app_insights_name" {
  description = "The name of the RTI Application Insights"
  value       = azurerm_application_insights.rti_app_insights.name
}

output "rti_app_insights_connection_string" {
  description = "The connection string of the RTI Application Insights"
  value       = azurerm_application_insights.rti_app_insights.connection_string
  sensitive   = true
}

output "rti_app_insights_instrumentation_key" {
  description = "The instrumentation key of the RTI Application Insights"
  value       = azurerm_application_insights.rti_app_insights.instrumentation_key
  sensitive   = true
}

# SQL Server / Database outputs
output "rti_sql_server_id" {
  description = "The ID of the RTI SQL Server"
  value       = azurerm_mssql_server.rti_sql_server.id
}

output "rti_sql_server_name" {
  description = "The name of the RTI SQL Server"
  value       = azurerm_mssql_server.rti_sql_server.name
}

output "rti_sql_server_fqdn" {
  description = "The fully qualified domain name of the RTI SQL Server"
  value       = azurerm_mssql_server.rti_sql_server.fully_qualified_domain_name
}

output "rti_sql_server_identity_principal_id" {
  description = "The Principal ID of the RTI SQL Server's system-assigned managed identity"
  value       = azurerm_mssql_server.rti_sql_server.identity[0].principal_id
}

output "rti_database_id" {
  description = "The ID of the RTI SQL Database"
  value       = azurerm_mssql_database.rti_database.id
}

output "rti_database_name" {
  description = "The name of the RTI SQL Database"
  value       = azurerm_mssql_database.rti_database.name
}

resource "azurerm_application_insights" "ccl_app_insights" {
  name                = var.ccl_app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name

  application_type = "web"
  workspace_id     = azurerm_log_analytics_workspace.ccl_law.id

  tags = merge(
    {
      displayName = "AppInsightsComponent"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.Insights/components",
      {}
    )
  )
}

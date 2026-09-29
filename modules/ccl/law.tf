resource "azurerm_log_analytics_workspace" "ccl_law" {
  name                = var.ccl_law_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    {
      displayName = "LogAnalyticsWorkspace"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.OperationalInsights/workspaces",
      {}
    )
  )
}

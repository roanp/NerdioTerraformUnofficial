resource "azurerm_service_plan" "rti_app_service_plan" {
  name                = var.rti_app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  os_type  = "Windows"
  sku_name = var.rti_app_service_plan_sku_name

  tags = merge(
    {
      NMW_OBJECT_TYPE = "PAAS"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.Web/serverfarms",
      {}
    )
  )
}

resource "azurerm_windows_web_app" "rti_app" {
  name                = var.rti_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.rti_app_service_plan.id

  public_network_access_enabled = (var.configure_private_endpoints && var.private_rti_app) ? false : true
  virtual_network_subnet_id     = var.app_subnet_id

  https_only              = true
  client_affinity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    http2_enabled       = true
    ftps_state          = "Disabled"
    minimum_tls_version = "1.3"
    use_32_bit_worker   = false
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v10.0"
    }
  }

  app_settings = {
    "ApplicationInsights:ConnectionString"   = azurerm_application_insights.rti_app_insights.connection_string
    "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.rti_app_insights.instrumentation_key
  }

  tags = merge(
    {
      NMW_OBJECT_TYPE = "PAAS"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.Web/sites",
      {}
    )
  )

  depends_on = [
    azurerm_application_insights.rti_app_insights
  ]
}

resource "azurerm_private_endpoint" "rti_app" {
  count               = var.configure_private_endpoints ? 1 : 0
  name                = "${var.rti_app_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id
  tags                = lookup(var.tags_by_resource, "Microsoft.Network/privateEndpoints", {})

  private_service_connection {
    name                           = "${var.rti_app_name}-pls"
    private_connection_resource_id = azurerm_windows_web_app.rti_app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.app_service_private_dns_zone_id]
  }
}

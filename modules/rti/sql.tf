resource "azurerm_mssql_server" "rti_sql_server" {
  name                          = var.rti_sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.configure_private_endpoints ? false : true

  azuread_administrator {
    login_username              = data.azuread_service_principal.current.display_name
    object_id                   = data.azurerm_client_config.current.client_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    {
      displayName = "SqlServer"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.Sql/servers",
      {}
    )
  )
}

# Grant Directory.Read.All to the RTI SQL Server's system-assigned managed identity.
resource "azuread_app_role_assignment" "rti_sql_directory_read_all" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
  principal_object_id = azurerm_mssql_server.rti_sql_server.identity[0].principal_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azurerm_mssql_database" "rti_database" {
  name        = var.rti_database_name
  server_id   = azurerm_mssql_server.rti_sql_server.id
  collation   = var.rti_sql_collation
  max_size_gb = var.rti_database_max_size_gb

  sku_name = var.rti_database_sku_name

  tags = merge(
    {
      displayName     = "Database"
      NMW_OBJECT_TYPE = "PAAS"
    },
    lookup(
      var.tags_by_resource,
      "Microsoft.Sql/servers/databases",
      {}
    )
  )
}

resource "azurerm_mssql_firewall_rule" "rti_allow_azure_ips" {
  count = var.configure_private_endpoints ? 0 : 1

  name      = "AllowAllWindowsAzureIps"
  server_id = azurerm_mssql_server.rti_sql_server.id

  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

data "http" "rti_deployer_ip" {
  count = var.configure_private_endpoints ? 0 : 1
  url   = "https://api.ipify.org"
}

resource "azurerm_mssql_firewall_rule" "rti_allow_deployer_ip" {
  count = var.configure_private_endpoints ? 0 : 1

  name      = "AllowDeployerIP"
  server_id = azurerm_mssql_server.rti_sql_server.id

  start_ip_address = trimspace(data.http.rti_deployer_ip[0].response_body)
  end_ip_address   = trimspace(data.http.rti_deployer_ip[0].response_body)
}

resource "azurerm_private_endpoint" "rti_sql_server" {
  count               = var.configure_private_endpoints ? 1 : 0
  name                = "${var.rti_sql_server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id
  tags                = lookup(var.tags_by_resource, "Microsoft.Network/privateEndpoints", {})

  private_service_connection {
    name                           = "${var.rti_sql_server_name}-pls"
    private_connection_resource_id = azurerm_mssql_server.rti_sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.sql_private_dns_zone_id]
  }
}

resource "azurerm_management_lock" "rti_sql_database_lock" {
  count      = var.protect_resources ? 1 : 0
  name       = "${var.rti_database_name}-lock"
  scope      = azurerm_mssql_database.rti_database.id
  lock_level = "CanNotDelete"
  notes      = "Database should not be deleted."
}

# Bootstrap SQL contained users so Nerdio Manager and the RTI Web App can access
# the database without a connection-string secret:
#   - The existing NME app's service principal (var.nme_service_principal_name)
#     is what Nerdio Manager itself uses to connect to a "selected SQL Server"
#     from its UI — without a DB user for it, NME reports "Failed to connect...
#     ensure Nerdio Manager's Service Principal has enough permissions."
#   - The RTI Web App's own system-assigned identity, in case RTI's own app
#     connects directly too.
# No new app registration or service principal is created for RTI itself
# (Entra ID app configuration is handled manually) — this only grants the
# already-existing NME service principal access to this database, mirroring
# modules/service's own SQL user bootstrap.
resource "null_resource" "rti_sql_user_setup" {
  triggers = {
    sp_name    = var.nme_service_principal_name
    mi_name    = var.rti_app_name
    sql_server = azurerm_mssql_server.rti_sql_server.fully_qualified_domain_name
    database   = azurerm_mssql_database.rti_database.name
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = 'Stop'

      $spName = '${var.nme_service_principal_name}'
      if ($spName.Contains('[') -or $spName.Contains(']') -or $spName.Contains("'")) {
        throw "Service Principal name contains invalid characters"
      }

      $miName = '${var.rti_app_name}'
      if ($miName.Contains('[') -or $miName.Contains(']') -or $miName.Contains("'")) {
        throw "Web App name contains invalid characters"
      }

      # Authenticate to Azure using ARM env vars
      . '${path.module}/scripts/connect-azure.ps1' -Environment '${var.azure_environment}' -SubscriptionId '${data.azurerm_client_config.current.subscription_id}'

      # Get token for database scope
      if (-not (Get-Command Get-AzAccessToken).Parameters.AsSecureString) {
          $sqlToken = (Get-AzAccessToken -ResourceUrl '${local.database_scope}').Token
      } else {
          $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR((Get-AzAccessToken -AsSecureString -ResourceUrl '${local.database_scope}').Token)
          try { $sqlToken = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) } finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
      }

      $connectionString = "Data Source=tcp:${azurerm_mssql_server.rti_sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.rti_database.name};Persist Security Info=False;Multiple Active Result Sets=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=False"

      # A freshly-created Azure AD principal can take a short while to replicate
      # before Azure SQL's "FROM EXTERNAL PROVIDER" lookup can resolve it by
      # display name. Retry on that specific transient failure; a genuine
      # duplicate display name is not retryable and fails fast with guidance.
      function Invoke-SqlUserBootstrap {
        param($ConnectionString, $AccessToken, $Query, $PrincipalName, $MaxAttempts = 10, $DelaySeconds = 15)
        for ($i = 1; $i -le $MaxAttempts; $i++) {
          try {
            Invoke-Sqlcmd -ConnectionString $ConnectionString -AccessToken $AccessToken -Query $Query -ErrorAction Stop
            return
          }
          catch {
            $msg = $_.Exception.Message
            if ($msg -match 'duplicate display name') {
              throw "Principal '$PrincipalName' has a duplicate display name in Microsoft Entra ID. This means two Entra ID objects (e.g. an orphaned app registration/service principal left over from a prior failed or reset deployment) share this exact name. Find and delete the one that is NOT tracked in Terraform state, then re-apply. Original error: $msg"
            }
            if ($msg -match 'does not exist or you do not have permission' -and $i -lt $MaxAttempts) {
              Write-Host "Attempt $i/$MaxAttempts: principal '$PrincipalName' not yet resolvable in Entra ID (replication delay). Retrying in $DelaySeconds s..."
              Start-Sleep -Seconds $DelaySeconds
              continue
            }
            throw
          }
        }
        throw "Timed out waiting for principal '$PrincipalName' to become resolvable in Entra ID after $MaxAttempts attempts."
      }

      $spQuery = @"
      IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$spName')
      BEGIN
        CREATE USER [$spName] FROM EXTERNAL PROVIDER;
      END
      ALTER ROLE db_ddladmin ADD MEMBER [$spName];
      ALTER ROLE db_datareader ADD MEMBER [$spName];
      ALTER ROLE db_datawriter ADD MEMBER [$spName];
      "@

      Invoke-SqlUserBootstrap -ConnectionString $connectionString -AccessToken $sqlToken -Query $spQuery -PrincipalName $spName

      Write-Host "SQL user setup completed for '$spName'"

      $miQuery = @"
      IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$miName')
      BEGIN
        CREATE USER [$miName] FROM EXTERNAL PROVIDER;
      END
      ALTER ROLE db_ddladmin ADD MEMBER [$miName];
      ALTER ROLE db_datareader ADD MEMBER [$miName];
      ALTER ROLE db_datawriter ADD MEMBER [$miName];
      "@

      Invoke-SqlUserBootstrap -ConnectionString $connectionString -AccessToken $sqlToken -Query $miQuery -PrincipalName $miName

      Write-Host "SQL user setup completed for managed identity '$miName'"
    EOT
  }

  depends_on = [
    azurerm_windows_web_app.rti_app,
    azurerm_mssql_server.rti_sql_server,
    azurerm_mssql_database.rti_database,
    azurerm_mssql_firewall_rule.rti_allow_azure_ips,
    azurerm_mssql_firewall_rule.rti_allow_deployer_ip,
    azuread_app_role_assignment.rti_sql_directory_read_all,
    null_resource.wait_for_rti_sql_private_dns,
  ]
}

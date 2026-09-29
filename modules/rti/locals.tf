locals {
  cloud_config = {
    AzureCloud = {
      sql_server_suffix = "database.windows.net"
    }
    AzureUSGovernment = {
      sql_server_suffix = "database.usgovcloudapi.net"
    }
    AzureChinaCloud = {
      sql_server_suffix = "database.chinacloudapi.cn"
    }
  }

  _env = local.cloud_config[var.azure_environment]

  sql_server_suffix = ".${local._env.sql_server_suffix}"
  database_scope    = "https://${local._env.sql_server_suffix}"

  # From Bicep: contains(unpairedRegions, toLower(location)) ? 'Standard_ZRS' : 'Standard_GRS'
  unpaired_regions = toset([
    "austriaeast",
    "belgiumcentral",
    "chilecentral",
    "indonesiacentral",
    "israelcentral",
    "italynorth",
    "malaysiawest",
    "mexicocentral",
    "newzealandnorth",
    "polandcentral",
    "qatarcentral",
    "spaincentral",
  ])

  storage_replication_type = contains(local.unpaired_regions, lower(var.location)) ? "ZRS" : "GRS"
}

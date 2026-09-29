variable "resource_group_name" {
  description = "Resource group name where all RTI resources are created"
  type        = string
}

variable "location" {
  description = "Location for all RTI resources"
  type        = string
}

variable "azure_environment" {
  description = "Azure environment name (AzureCloud, AzureUSGovernment, AzureChinaCloud)"
  type        = string

  validation {
    condition     = contains(["AzureCloud", "AzureUSGovernment", "AzureChinaCloud"], var.azure_environment)
    error_message = "azure_environment must be one of: AzureCloud, AzureUSGovernment, AzureChinaCloud."
  }
}

variable "nme_service_principal_name" {
  description = "Display name of the existing Nerdio Manager (NME) Azure AD application's service principal (modules/service's azuread_app_name). Granted as a SQL contained database user so Nerdio Manager can connect to the RTI database from its UI."
  type        = string
}

variable "protect_resources" {
  description = "Specifies whether RTI resources should be protected with management locks"
  type        = bool
  default     = false
}

variable "tags_by_resource" {
  description = "Optional extra tags by resource"
  type        = map(map(string))
  default     = {}
}

variable "rti_app_name" {
  description = "Name for the RTI Web App resource"
  type        = string
}

variable "rti_app_service_plan_name" {
  description = "Name for the RTI App Service Plan resource"
  type        = string
}

variable "rti_app_service_plan_sku_name" {
  description = "SKU name for the RTI App Service Plan (e.g., P0v3, P1v3)"
  type        = string
}

variable "rti_key_vault_name" {
  description = "Name for the RTI Key Vault resource"
  type        = string
}

variable "rti_storage_account_name" {
  description = "Name for the RTI Storage Account resource"
  type        = string
}

variable "rti_law_name" {
  description = "Name for the RTI Log Analytics Workspace resource"
  type        = string
}

variable "rti_app_insights_name" {
  description = "Name for the RTI Application Insights resource"
  type        = string
}

variable "rti_sql_server_name" {
  description = "Name for the RTI SQL Server resource"
  type        = string
}

variable "rti_database_name" {
  description = "Name for the RTI SQL Database resource"
  type        = string
}

variable "rti_sql_collation" {
  description = "Collation for the RTI SQL database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "rti_database_max_size_gb" {
  description = "Maximum size of the RTI SQL database in gigabytes"
  type        = number
  default     = 250
}

variable "rti_database_sku_name" {
  description = "SKU name for the RTI SQL database (e.g., S0, S1, S2)"
  type        = string
}

variable "private_rti_app" {
  description = "Whether the RTI Web App should be accessible only via private endpoint"
  type        = bool
  default     = false
}

variable "configure_private_endpoints" {
  description = "Specifies whether private endpoints will be configured for RTI resources. When true, the private_endpoints_subnet_id, app_subnet_id, and *_private_dns_zone_id variables are required (they are expected to come from the already-deployed modules/service network)."
  type        = bool
  default     = false
}

variable "private_endpoint_post_resolve_delay" {
  description = "Extra delay in seconds after private endpoint DNS resolves and TCP connectivity is confirmed. Increase (e.g. 30-60) if the SQL user bootstrap fails with connectivity errors."
  type        = number
  default     = 0

  validation {
    condition     = var.private_endpoint_post_resolve_delay >= 0 && floor(var.private_endpoint_post_resolve_delay) == var.private_endpoint_post_resolve_delay
    error_message = "private_endpoint_post_resolve_delay must be a non-negative whole number of seconds (e.g. 0, 30, 60)."
  }
}

variable "private_endpoints_subnet_id" {
  description = "Subnet ID to attach RTI private endpoints to (from modules/service's private endpoints subnet). Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.private_endpoints_subnet_id != null
    error_message = "private_endpoints_subnet_id is required when configure_private_endpoints is true."
  }
}

variable "app_subnet_id" {
  description = "Delegated subnet ID for the RTI Web App's VNet integration (from modules/service's app subnet). Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.app_subnet_id != null
    error_message = "app_subnet_id is required when configure_private_endpoints is true."
  }
}

variable "key_vault_private_dns_zone_id" {
  description = "ID of the existing Key Vault private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.key_vault_private_dns_zone_id != null
    error_message = "key_vault_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

variable "blob_private_dns_zone_id" {
  description = "ID of the existing Blob Storage private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.blob_private_dns_zone_id != null
    error_message = "blob_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

variable "app_service_private_dns_zone_id" {
  description = "ID of the existing App Service private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.app_service_private_dns_zone_id != null
    error_message = "app_service_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

variable "sql_private_dns_zone_id" {
  description = "ID of the existing SQL Server private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.sql_private_dns_zone_id != null
    error_message = "sql_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

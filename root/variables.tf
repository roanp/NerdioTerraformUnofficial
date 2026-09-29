variable "resource_group_name" {
  description = "Name of the resource group where all resources will be created"
  type        = string
}

variable "azuread_app_name" {
  description = "Name of the Azure AD application to create/use for the service"
  type        = string
}

variable "disable_implicit_grant_token_issuance" {
  description = "Disable access and ID token issuance for implicit grant and hybrid flows. Set to false only to restore the legacy enabled behavior."
  type        = bool
  default     = true
}

variable "azure_environment" {
  description = "Azure environment name (AzureCloud, AzureUSGovernment, AzureChinaCloud)"
  type        = string
}

variable "subscription_display_name" {
  description = "Human-readable subscription name (informational)"
  type        = string
}


variable "location" {
  description = "Azure region where all resources will be deployed"
  type        = string
}

variable "protect_resources" {
  description = "Whether to apply management locks to critical resources (Key Vault, SQL Database, Storage)"
  type        = bool
  default     = false
}

variable "azure_tag_prefix" {
  description = "Prefix used for custom Azure tags"
  type        = string
}

variable "app_service_plan_sku_name" {
  description = "SKU name for the App Service Plan (e.g., B1, B2, B3, S1, P1v2)"
  type        = string
}

variable "sql_collation" {
  description = "Collation for the SQL database"
  type        = string
}

variable "database_max_size_gb" {
  description = "Maximum size of the SQL database in gigabytes"
  type        = number
  default     = 250
}

variable "database_sku_name" {
  description = "SKU name for the SQL database (e.g., S0, S1, P1)"
  type        = string
}

variable "tags_by_resource" {
  description = "Map of resource type to tags. Allows applying specific tags to different Azure resource types"
  type        = map(map(string))
  default     = {}
}

variable "configure_private_endpoints" {
  description = "Whether to configure private endpoints for services"
  type        = bool
  default     = false
}

variable "deployment_vnet_name" {
  description = "VNet from which TF deployment is executed. Required when configure_private_endpoints = true."
  type        = string
  default     = null
}

variable "deployment_resource_group_name" {
  description = "Resource group from which TF deployment is executed. Required when configure_private_endpoints = true."
  type        = string
  default     = null
}

variable "network_config" {
  description = "Network configuration for private endpoints. Required when configure_private_endpoints = true."
  type = object({
    vnet_name       = string
    vnet_cidr       = string
    pe_subnet_name  = string
    pe_subnet_cidr  = string
    app_subnet_name = string
    app_subnet_cidr = string
  })
  default = null
}

variable "private_web_app" {
  description = "Whether the Web App should be accessible only via private endpoint"
  type        = bool
  default     = false
}

variable "web_app_portal_name" {
  description = "Name for the Web App resource"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name for the App Service Plan resource"
  type        = string
}

variable "sql_server_name" {
  description = "Name for the SQL Server resource"
  type        = string
}

variable "database_name" {
  description = "Name for the SQL Database resource"
  type        = string
}

variable "key_vault_name" {
  description = "Name for the Key Vault resource"
  type        = string
}

variable "app_insights_name" {
  description = "Name for the Application Insights resource"
  type        = string
}

variable "automation_account_name" {
  description = "Name for the Automation Account used for NME updates"
  type        = string
}

variable "law_name" {
  description = "Name for the Log Analytics Workspace used for session host monitoring"
  type        = string
}

variable "logs_law_name" {
  description = "Name for the Log Analytics Workspace used for Application Insights"
  type        = string
}

variable "scripted_action_account_name" {
  description = "Name for the Automation Account used for Scripted Actions"
  type        = string
}

variable "data_protection_storage_account_name" {
  description = "Name for the Storage Account used for Data Protection keys"
  type        = string
}

variable "data_protection_keys_blob_name" {
  description = "Name of the blob file where Data Protection keys are stored"
  type        = string
}

variable "data_protection_key_name" {
  description = "Name of the Data Protection Key"
  type        = string
  default     = "DataProtection-main"
}

variable "maintenance_service_url" {
  description = "Maintenance service URL"
  type        = string
  default     = "https://nwp-web-app.azurewebsites.net"
}

variable "app_package_version" {
  description = "Application package version to request from the maintenance service (e.g. 1.0.0.0)"
  type        = string
  default     = "latest"
}

variable "app_package_local_path" {
  description = "Absolute path to a pre-downloaded NME application package .zip on the machine running Terraform. When set, the maintenance service is not contacted (offline/disconnected install) and app_package_version is ignored. The package archive must contain app.zip and related deployment files."
  type        = string
  default     = null

  validation {
    condition     = var.app_package_local_path == null || can(regex("(?i)\\.zip$", trimspace(var.app_package_local_path)))
    error_message = "app_package_local_path must point to a .zip file."
  }
}

variable "app_role_assignments" {
  description = "Optional map of app role names to lists of user principal names (emails) to assign to those roles. Roles: Reviewer, HelpDesk, DesktopAdmin, WvdAdmin, RestClient"
  type        = map(list(string))
  default     = {}
}


variable "private_endpoint_post_resolve_delay" {
  description = "Extra delay in seconds after private endpoint DNS resolves and TCP connectivity is confirmed. Increase (e.g. 30-60) if first apply with private endpoints fails with 403 errors."
  type        = number
  default     = 0
}

variable "app_cert_name" {
  description = "Name of the self-signed certificate in Key Vault used for Azure AD app authentication (for features that do not support Managed Identity)"
  type        = string
  default     = "nme-app-cert"
}

variable "app_cert_lifetime_months" {
  description = "Validity period in months for the Azure AD app authentication certificate"
  type        = number
  default     = 4

  validation {
    condition     = var.app_cert_lifetime_months >= 1 && var.app_cert_lifetime_months <= 297 && floor(var.app_cert_lifetime_months) == var.app_cert_lifetime_months
    error_message = "app_cert_lifetime_months must be a whole number between 1 and 297 (Key Vault supported range)."
  }
}

# -----------------
# Optional CCL module
# -----------------

variable "deploy_ccl_module" {
  description = "Whether to deploy the optional CCL module (App Service, Key Vault, Storage Account, Log Analytics Workspace, Application Insights) alongside the core NME service"
  type        = bool
  default     = false
}

variable "ccl_app_name" {
  description = "Name for the CCL Web App resource. Required when deploy_ccl_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_app_name != null
    error_message = "ccl_app_name is required when deploy_ccl_module is true."
  }
}

variable "ccl_use_existing_app_service_plan" {
  description = "Whether the CCL Web App should run on the existing core NME App Service Plan instead of a dedicated one. Typically true."
  type        = bool
  default     = true
}

variable "ccl_app_service_plan_name" {
  description = "Name for a dedicated CCL App Service Plan resource. Required when deploy_ccl_module = true and ccl_use_existing_app_service_plan = false."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_use_existing_app_service_plan == true || var.ccl_app_service_plan_name != null
    error_message = "ccl_app_service_plan_name is required when deploy_ccl_module is true and ccl_use_existing_app_service_plan is false."
  }
}

variable "ccl_app_service_plan_sku_name" {
  description = "SKU name for a dedicated CCL App Service Plan (e.g., B1, B2, B3, S1, P1v2). Required when deploy_ccl_module = true and ccl_use_existing_app_service_plan = false."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_use_existing_app_service_plan == true || var.ccl_app_service_plan_sku_name != null
    error_message = "ccl_app_service_plan_sku_name is required when deploy_ccl_module is true and ccl_use_existing_app_service_plan is false."
  }
}

variable "ccl_key_vault_name" {
  description = "Name for the CCL Key Vault resource. Required when deploy_ccl_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_key_vault_name != null
    error_message = "ccl_key_vault_name is required when deploy_ccl_module is true."
  }
}

variable "ccl_storage_account_name" {
  description = "Name for the CCL Storage Account resource. Required when deploy_ccl_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_storage_account_name != null
    error_message = "ccl_storage_account_name is required when deploy_ccl_module is true."
  }
}

variable "ccl_law_name" {
  description = "Name for the CCL Log Analytics Workspace resource. Required when deploy_ccl_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_law_name != null
    error_message = "ccl_law_name is required when deploy_ccl_module is true."
  }
}

variable "ccl_app_insights_name" {
  description = "Name for the CCL Application Insights resource. Required when deploy_ccl_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_ccl_module == false || var.ccl_app_insights_name != null
    error_message = "ccl_app_insights_name is required when deploy_ccl_module is true."
  }
}

variable "private_ccl_app" {
  description = "Whether the CCL Web App should be accessible only via private endpoint"
  type        = bool
  default     = false
}

# -----------------
# Optional RTI module
# -----------------

variable "deploy_rti_module" {
  description = "Whether to deploy the optional RTI module (App Service, Key Vault, Storage Account, Log Analytics Workspace, Application Insights, SQL Server + Database) alongside the core NME service"
  type        = bool
  default     = false
}

variable "rti_app_name" {
  description = "Name for the RTI Web App resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_app_name != null
    error_message = "rti_app_name is required when deploy_rti_module is true."
  }
}

variable "rti_app_service_plan_name" {
  description = "Name for the RTI App Service Plan resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_app_service_plan_name != null
    error_message = "rti_app_service_plan_name is required when deploy_rti_module is true."
  }
}

variable "rti_app_service_plan_sku_name" {
  description = "SKU name for the RTI App Service Plan (e.g., P0v3, P1v3). Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_app_service_plan_sku_name != null
    error_message = "rti_app_service_plan_sku_name is required when deploy_rti_module is true."
  }
}

variable "rti_key_vault_name" {
  description = "Name for the RTI Key Vault resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_key_vault_name != null
    error_message = "rti_key_vault_name is required when deploy_rti_module is true."
  }
}

variable "rti_storage_account_name" {
  description = "Name for the RTI Storage Account resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_storage_account_name != null
    error_message = "rti_storage_account_name is required when deploy_rti_module is true."
  }
}

variable "rti_law_name" {
  description = "Name for the RTI Log Analytics Workspace resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_law_name != null
    error_message = "rti_law_name is required when deploy_rti_module is true."
  }
}

variable "rti_app_insights_name" {
  description = "Name for the RTI Application Insights resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_app_insights_name != null
    error_message = "rti_app_insights_name is required when deploy_rti_module is true."
  }
}

variable "rti_sql_server_name" {
  description = "Name for the RTI SQL Server resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_sql_server_name != null
    error_message = "rti_sql_server_name is required when deploy_rti_module is true."
  }
}

variable "rti_database_name" {
  description = "Name for the RTI SQL Database resource. Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_database_name != null
    error_message = "rti_database_name is required when deploy_rti_module is true."
  }
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
  description = "SKU name for the RTI SQL database (e.g., S0, S1, S2). Required when deploy_rti_module = true."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_rti_module == false || var.rti_database_sku_name != null
    error_message = "rti_database_sku_name is required when deploy_rti_module is true."
  }
}

variable "private_rti_app" {
  description = "Whether the RTI Web App should be accessible only via private endpoint"
  type        = bool
  default     = false
}


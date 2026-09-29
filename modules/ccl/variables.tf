variable "resource_group_name" {
  description = "Resource group name where all CCL resources are created"
  type        = string
}

variable "location" {
  description = "Location for all CCL resources"
  type        = string
}

variable "protect_resources" {
  description = "Specifies whether CCL resources should be protected with management locks"
  type        = bool
  default     = false
}

variable "tags_by_resource" {
  description = "Optional extra tags by resource"
  type        = map(map(string))
  default     = {}
}

variable "ccl_app_name" {
  description = "Name for the CCL Web App resource"
  type        = string
}

variable "use_existing_app_service_plan" {
  description = "Whether the CCL Web App should run on an existing App Service Plan (typically the core NME App Service Plan) instead of a dedicated one"
  type        = bool
  default     = true
}

variable "existing_app_service_plan_id" {
  description = "ID of the existing App Service Plan to run the CCL Web App on. Required when use_existing_app_service_plan = true."
  type        = string
  default     = null

  validation {
    condition     = var.use_existing_app_service_plan == false || var.existing_app_service_plan_id != null
    error_message = "existing_app_service_plan_id is required when use_existing_app_service_plan is true."
  }
}

variable "ccl_app_service_plan_name" {
  description = "Name for a dedicated CCL App Service Plan resource. Required when use_existing_app_service_plan = false."
  type        = string
  default     = null

  validation {
    condition     = var.use_existing_app_service_plan == true || var.ccl_app_service_plan_name != null
    error_message = "ccl_app_service_plan_name is required when use_existing_app_service_plan is false."
  }
}

variable "ccl_app_service_plan_sku_name" {
  description = "SKU name for a dedicated CCL App Service Plan (e.g., B1, B2, B3, S1, P1v2). Required when use_existing_app_service_plan = false."
  type        = string
  default     = null

  validation {
    condition     = var.use_existing_app_service_plan == true || var.ccl_app_service_plan_sku_name != null
    error_message = "ccl_app_service_plan_sku_name is required when use_existing_app_service_plan is false."
  }
}

variable "ccl_key_vault_name" {
  description = "Name for the CCL Key Vault resource"
  type        = string
}

variable "ccl_storage_account_name" {
  description = "Name for the CCL Storage Account resource"
  type        = string
}

variable "ccl_law_name" {
  description = "Name for the CCL Log Analytics Workspace resource"
  type        = string
}

variable "ccl_app_insights_name" {
  description = "Name for the CCL Application Insights resource"
  type        = string
}

variable "private_ccl_app" {
  description = "Whether the CCL Web App should be accessible only via private endpoint"
  type        = bool
  default     = false
}

variable "configure_private_endpoints" {
  description = "Specifies whether private endpoints will be configured for CCL resources. When true, the private_endpoints_subnet_id, app_subnet_id, and *_private_dns_zone_id variables are required (they are expected to come from the already-deployed modules/service network)."
  type        = bool
  default     = false
}

variable "private_endpoints_subnet_id" {
  description = "Subnet ID to attach CCL private endpoints to (from modules/service's private endpoints subnet). Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.private_endpoints_subnet_id != null
    error_message = "private_endpoints_subnet_id is required when configure_private_endpoints is true."
  }
}

variable "app_subnet_id" {
  description = "Delegated subnet ID for the CCL Web App's VNet integration (from modules/service's app subnet). Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.app_subnet_id != null
    error_message = "app_subnet_id is required when configure_private_endpoints is true."
  }
}

variable "key_vault_private_dns_zone_id" {
  description = "ID of the existing privatelink.vaultcore.azure.net (or cloud equivalent) private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.key_vault_private_dns_zone_id != null
    error_message = "key_vault_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

variable "blob_private_dns_zone_id" {
  description = "ID of the existing privatelink.blob.core.windows.net (or cloud equivalent) private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.blob_private_dns_zone_id != null
    error_message = "blob_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

variable "app_service_private_dns_zone_id" {
  description = "ID of the existing privatelink.azurewebsites.net (or cloud equivalent) private DNS zone from modules/service. Required when configure_private_endpoints = true."
  type        = string
  default     = null

  validation {
    condition     = var.configure_private_endpoints == false || var.app_service_private_dns_zone_id != null
    error_message = "app_service_private_dns_zone_id is required when configure_private_endpoints is true."
  }
}

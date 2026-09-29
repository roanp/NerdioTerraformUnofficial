locals {
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

  ccl_service_plan_id = var.use_existing_app_service_plan ? var.existing_app_service_plan_id : azurerm_service_plan.ccl_app_service_plan[0].id
}

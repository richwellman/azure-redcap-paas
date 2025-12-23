# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Locals for computed values
locals {
  # Compute resource group name if not explicitly provided
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "rg-redcap-${var.environment}-${var.sequence}"

  # Key Vault names (must be globally unique, 3-24 characters)
  key_vault_base_name = "kv-redcap${random_string.suffix.result}-${var.environment}-${var.sequence}"
  key_vault_name      = substr(local.key_vault_base_name, 0, 24)

  # Key Vault private endpoint name
  keyvault_private_endpoint_name = "pe-${local.key_vault_name}"

  # Storage Account names (must be globally unique, 3-24 lowercase alphanumeric, no hyphens)
  storage_account_base_name = "stredcap${random_string.suffix.result}${var.environment}${var.sequence}"
  storage_account_name      = substr(replace(local.storage_account_base_name, "-", ""), 0, 24)

  # Storage private endpoint name
  storage_private_endpoint_name = "pe-${local.storage_account_name}"

  # MySQL Flexible Server names (must be globally unique, 3-63 lowercase with hyphens)
  mysql_server_name = "mysql-redcap-${random_string.suffix.result}-${var.environment}-${var.sequence}"

  # MySQL private endpoint name
  mysql_private_endpoint_name = "pe-${local.mysql_server_name}"

  # App Service Plan name (only needs to be unique within resource group)
  app_service_plan_name = "plan-redcap-${var.environment}-${var.sequence}"

  # App Service name (must be globally unique)
  app_service_name      = "app-redcap-${random_string.suffix.result}-${var.environment}-${var.sequence}"

  # App Service private endpoint name
  app_service_private_endpoint_name = "pe-${local.app_service_name}"

  # User Assigned Managed Identity name (only needs to be unique within resource group)
  uami_name = "uami-redcap-${var.environment}-${var.sequence}"

  common_tags = merge(
    var.tags,
    {
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  )
}

# Single Resource Group for all REDCap Resources
resource "azurerm_resource_group" "redcap" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

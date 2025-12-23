# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the REDCap resource group"
  value       = azurerm_resource_group.redcap.name
}

output "resource_group_id" {
  description = "ID of the REDCap resource group"
  value       = azurerm_resource_group.redcap.id
}

output "resource_group_location" {
  description = "Location of the REDCap resource group"
  value       = azurerm_resource_group.redcap.location
}

# Network Outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.redcap_vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.redcap_vnet.name
}

output "private_link_subnet_id" {
  description = "ID of the PrivateLinkSubnet"
  value       = azurerm_subnet.private_link.id
}

output "compute_subnet_id" {
  description = "ID of the ComputeSubnet"
  value       = azurerm_subnet.compute.id
}

output "integration_subnet_id" {
  description = "ID of the IntegrationSubnet"
  value       = azurerm_subnet.integration.id
}

output "mysql_flex_subnet_id" {
  description = "ID of the MySQLFlexSubnet"
  value       = azurerm_subnet.mysql_flex.id
}

# Storage Outputs
output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.redcap.id
}

output "storage_account_name" {
  description = "Name of the storage account (computed from locals)"
  value       = azurerm_storage_account.redcap.name
}

output "storage_account_computed_name" {
  description = "Computed storage account name from locals"
  value       = local.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.redcap.primary_blob_endpoint
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.redcap.primary_access_key
  sensitive   = true
}

output "blob_container_name" {
  description = "Name of the REDCap blob container"
  value       = azurerm_storage_container.redcap.name
}

output "storage_private_endpoint_id" {
  description = "ID of the storage private endpoint"
  value       = azurerm_private_endpoint.storage.id
}

output "blob_private_dns_zone_id" {
  description = "ID of the blob private DNS zone"
  value       = azurerm_private_dns_zone.blob.id
}

# Key Vault Outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.redcap.id
}

output "key_vault_name" {
  description = "Name of the Key Vault (computed from locals)"
  value       = azurerm_key_vault.redcap.name
}

output "key_vault_computed_name" {
  description = "Computed Key Vault name from locals"
  value       = local.key_vault_name
}

output "random_suffix" {
  description = "Random suffix used for globally unique resource names"
  value       = random_string.suffix.result
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.redcap.vault_uri
}

output "keyvault_private_endpoint_id" {
  description = "ID of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.keyvault.id
}

output "keyvault_private_dns_zone_id" {
  description = "ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.keyvault.id
}

output "key_vault_tenant_id" {
  description = "Tenant ID associated with the Key Vault"
  value       = azurerm_key_vault.redcap.tenant_id
}

# MySQL Database Outputs
output "mysql_server_id" {
  description = "ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.redcap.id
}

output "mysql_server_name" {
  description = "Name of the MySQL Flexible Server (computed from locals)"
  value       = azurerm_mysql_flexible_server.redcap.name
}

output "mysql_server_computed_name" {
  description = "Computed MySQL server name from locals"
  value       = local.mysql_server_name
}

output "mysql_server_fqdn" {
  description = "Fully qualified domain name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.redcap.fqdn
}

output "mysql_database_name" {
  description = "Name of the MySQL database"
  value       = azurerm_mysql_flexible_database.redcap.name
}

output "mysql_admin_username" {
  description = "MySQL administrator username"
  value       = azurerm_mysql_flexible_server.redcap.administrator_login
  sensitive   = true
}

output "mysql_private_endpoint_id" {
  description = "ID of the MySQL private endpoint"
  value       = azurerm_private_endpoint.mysql.id
}

output "mysql_private_dns_zone_id" {
  description = "ID of the MySQL private DNS zone"
  value       = azurerm_private_dns_zone.mysql.id
}

# Web App Outputs
output "uami_id" {
  description = "ID of the User-Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.redcap.id
}

output "uami_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.redcap.principal_id
}

output "uami_client_id" {
  description = "Client ID of the User-Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.redcap.client_id
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.redcap.id
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.redcap.id
}

output "app_service_name" {
  description = "Name of the App Service (computed from locals)"
  value       = azurerm_linux_web_app.redcap.name
}

output "app_service_computed_name" {
  description = "Computed App Service name from locals"
  value       = local.app_service_name
}

output "app_service_plan_computed_name" {
  description = "Computed App Service Plan name from locals"
  value       = local.app_service_plan_name
}

output "uami_computed_name" {
  description = "Computed User-Assigned Managed Identity name from locals"
  value       = local.uami_name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.redcap.default_hostname
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_linux_web_app.redcap.default_hostname}"
}

output "app_service_outbound_ip_addresses" {
  description = "Outbound IP addresses of the App Service"
  value       = azurerm_linux_web_app.redcap.outbound_ip_addresses
}

output "app_service_private_endpoint_id" {
  description = "ID of the App Service private endpoint"
  value       = azurerm_private_endpoint.webapp.id
}

output "webapp_private_dns_zone_id" {
  description = "ID of the App Service private DNS zone"
  value       = azurerm_private_dns_zone.webapp.id
}

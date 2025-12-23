# User-Assigned Managed Identity
resource "azurerm_user_assigned_identity" "redcap" {
  name                = local.uami_name
  resource_group_name = azurerm_resource_group.redcap.name
  location            = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

# App Service Plan
resource "azurerm_service_plan" "redcap" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.redcap.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku_name

  lifecycle {
    ignore_changes = [tags]
  }
}

# App Service
resource "azurerm_linux_web_app" "redcap" {
  name                = local.app_service_name
  resource_group_name = azurerm_resource_group.redcap.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.redcap.id

  https_only                      = true
  public_network_access_enabled   = true
  virtual_network_subnet_id       = azurerm_subnet.integration.id
  key_vault_reference_identity_id = azurerm_user_assigned_identity.redcap.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.redcap.id]
  }

  site_config {
    always_on              = true
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    ftps_state             = "FtpsOnly"
    vnet_route_all_enabled = true

    application_stack {
      php_version = var.app_service_php_version
    }

    app_command_line = var.app_service_startup_command
  }

  app_settings = {
    # REDCap Zip Configuration
    "redcapAppZip" = var.redcap_zip_url

    # Database Configuration
    "DBHostName" = azurerm_mysql_flexible_server.redcap.fqdn
    "DBName"     = azurerm_mysql_flexible_database.redcap.name
    "DBUserName" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.redcap.vault_uri}secrets/sqlAdminName/)"
    "DBPassword" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.redcap.vault_uri}secrets/sqlPassword/)"
    "DBSslCa"    = "/home/site/wwwroot/DigiCertGlobalRootG2.crt.pem"

    # REDCap Community Credentials
    "redcapCommunityUsername" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.redcap.vault_uri}secrets/redcapCommunityUsername/)"
    "redcapCommunityPassword" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.redcap.vault_uri}secrets/redcapCommunityPassword/)"

    # SMTP Configuration
    "smtpFQDN"          = var.smtp_fqdn
    "smtpPort"          = var.smtp_port
    "fromEmailAddress"  = var.smtp_from_email_address

    # Application Insights
    #"APPINSIGHTS_INSTRUMENTATIONKEY"        = var.app_insights_instrumentation_key
    #"APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string

    # Source Control Management
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"

    # Storage Account Configuration
    "StorageKey"           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.redcap.vault_uri}secrets/storageKey/)"
    "StorageAccount"       = azurerm_storage_account.redcap.name
    "StorageContainerName" = azurerm_storage_container.redcap.name

    # REDCap Dynamic Install
    "ENABLE_DYNAMIC_INSTALL" = "true"
  }

  depends_on = [
    azurerm_key_vault_secret.sql_admin_name,
    azurerm_key_vault_secret.sql_password,
    azurerm_key_vault_secret.storage_key,
    azurerm_mysql_flexible_server.redcap,
    azurerm_storage_account.redcap
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Source Control Configuration (External Git)
resource "azurerm_app_service_source_control" "redcap" {
  app_id                 = azurerm_linux_web_app.redcap.id
  repo_url               = var.scm_repo_url
  branch                 = var.scm_repo_branch
  use_manual_integration = true
  use_mercurial          = false

  depends_on = [azurerm_linux_web_app.redcap]
}

# Private DNS Zone for App Service
resource "azurerm_private_dns_zone" "webapp" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.redcap.name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "webapp_vnet_link" {
  name                  = "vnetlink"
  resource_group_name   = azurerm_resource_group.redcap.name
  private_dns_zone_name = azurerm_private_dns_zone.webapp.name
  virtual_network_id    = azurerm_virtual_network.redcap_vnet.id
  registration_enabled  = false
}

# Private Endpoint for App Service
resource "azurerm_private_endpoint" "webapp" {
  name                = local.app_service_private_endpoint_name
  location            = var.location
  resource_group_name = azurerm_resource_group.redcap.name
  subnet_id           = azurerm_subnet.private_link.id

  private_service_connection {
    name                           = local.app_service_private_endpoint_name
    private_connection_resource_id = azurerm_linux_web_app.redcap.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.webapp.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

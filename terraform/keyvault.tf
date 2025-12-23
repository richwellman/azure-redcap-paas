# Key Vault
resource "azurerm_key_vault" "redcap" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.redcap.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  rbac_authorization_enabled = true

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = true

  public_network_access_enabled = var.enable_keyvault_public_access

  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.enable_keyvault_public_access ? "Allow" : "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  lifecycle {
    ignore_changes = [tags]
  }

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# RBAC Role Assignment: Grant Terraform deployment identity Key Vault Administrator access
resource "azurerm_role_assignment" "kv_admin_terraform" {
  scope                = azurerm_key_vault.redcap.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_key_vault.redcap]
}

# RBAC Role Assignment: Grant UAMI Key Vault Secrets User access (for App Service)
resource "azurerm_role_assignment" "kv_secrets_user_uami" {
  scope                = azurerm_key_vault.redcap.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.redcap.principal_id

  depends_on = [azurerm_key_vault.redcap]
}

# Key Vault Secrets (values must be provided separately)
resource "azurerm_key_vault_secret" "redcap_community_username" {
  name         = "redcapCommunityUsername"
  value        = var.redcap_community_username != "" ? var.redcap_community_username : "placeholder"
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_key_vault.redcap,
    azurerm_role_assignment.kv_admin_terraform
  ]

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_key_vault_secret" "redcap_community_password" {
  name         = "redcapCommunityPassword"
  value        = var.redcap_community_password != "" ? var.redcap_community_password : "placeholder"
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_key_vault.redcap,
    azurerm_role_assignment.kv_admin_terraform
  ]

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_key_vault_secret" "sql_admin_name" {
  name         = "sqlAdminName"
  value        = var.sql_admin_name != "" ? var.sql_admin_name : "sqladmin"
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_key_vault.redcap,
    azurerm_role_assignment.kv_admin_terraform
  ]

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sqlPassword"
  value        = var.sql_password != "" ? var.sql_password : "placeholder"
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_key_vault.redcap,
    azurerm_role_assignment.kv_admin_terraform
  ]

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_key_vault_secret" "storage_key" {
  name         = "storageKey"
  value        = azurerm_storage_account.redcap.primary_access_key
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_key_vault.redcap,
    azurerm_storage_account.redcap,
    azurerm_role_assignment.kv_admin_terraform
  ]

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.redcap.name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_vnet_link" {
  name                  = "vnetlink"
  resource_group_name   = azurerm_resource_group.redcap.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.redcap_vnet.id
  registration_enabled  = false
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = local.keyvault_private_endpoint_name
  location            = var.location
  resource_group_name = azurerm_resource_group.redcap.name
  subnet_id           = azurerm_subnet.private_link.id

  private_service_connection {
    name                           = local.keyvault_private_endpoint_name
    private_connection_resource_id = azurerm_key_vault.redcap.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

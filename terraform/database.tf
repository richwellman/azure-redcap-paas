# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "redcap" {
  name                   = local.mysql_server_name
  resource_group_name    = azurerm_resource_group.redcap.name
  location               = var.location
  administrator_login    = var.sql_admin_name
  administrator_password = var.sql_password

  backup_retention_days        = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = var.mysql_geo_redundant_backup == "Enabled"

  sku_name = var.mysql_sku_name
  version  = var.mysql_version

  storage {
    auto_grow_enabled = true
    iops              = var.mysql_storage_iops
    size_gb           = var.mysql_storage_size_gb
  }

  # High availability disabled by default
  # high_availability {
  #   mode = var.mysql_high_availability
  # }

  # Public network access disabled - only accessible via private endpoint
  # Note: In Terraform, we create private endpoint separately
  # The network block is commented out as we're using private endpoint instead
  # network {
  #   delegated_subnet_id = azurerm_subnet.mysql_flex.id
  #   private_dns_zone_id = azurerm_private_dns_zone.mysql.id
  # }

  depends_on = [
    azurerm_key_vault_secret.sql_admin_name,
    azurerm_key_vault_secret.sql_password
  ]

  lifecycle {
    ignore_changes = [tags]
  }

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "redcap" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.redcap.name
  server_name         = azurerm_mysql_flexible_server.redcap.name
  charset             = var.mysql_database_charset
  collation           = var.mysql_database_collation

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.redcap.name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet_link" {
  name                  = "vnetlink"
  resource_group_name   = azurerm_resource_group.redcap.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.redcap_vnet.id
  registration_enabled  = false
}

# Private Endpoint for MySQL Flexible Server
resource "azurerm_private_endpoint" "mysql" {
  name                = local.mysql_private_endpoint_name
  location            = var.location
  resource_group_name = azurerm_resource_group.redcap.name
  subnet_id           = azurerm_subnet.private_link.id

  private_service_connection {
    name                           = local.mysql_private_endpoint_name
    private_connection_resource_id = azurerm_mysql_flexible_server.redcap.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.mysql.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# MySQL Flexible Server Configuration - Disable invisible primary key
# Note: This requires the Az CLI and proper RBAC permissions
# In production, this should be done via a deployment script or manually
resource "azurerm_mysql_flexible_server_configuration" "invisible_primary_key" {
  name                = "sql_generate_invisible_primary_key"
  resource_group_name = azurerm_resource_group.redcap.name
  server_name         = azurerm_mysql_flexible_server.redcap.name
  value               = "OFF"

  depends_on = [azurerm_mysql_flexible_database.redcap]
}

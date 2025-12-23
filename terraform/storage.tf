# Storage Account
resource "azurerm_storage_account" "redcap" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.redcap.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = false
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  https_traffic_only_enabled       = true

  network_rules {
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = []
    ip_rules                   = []
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Blob Service - REDCap Container
resource "azurerm_storage_container" "redcap" {
  name                  = "redcap"
  storage_account_id    = azurerm_storage_account.redcap.id
  container_access_type = "private"

  # Uncomment for production to prevent accidental deletion:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.redcap.name

  lifecycle {
    ignore_changes = [tags]
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_vnet_link" {
  name                  = "vnetlink"
  resource_group_name   = azurerm_resource_group.redcap.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.redcap_vnet.id
  registration_enabled  = false
  resolution_policy     = "NxDomainRedirect"
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage" {
  name                = local.storage_private_endpoint_name
  location            = var.location
  resource_group_name = azurerm_resource_group.redcap.name
  subnet_id           = azurerm_subnet.private_link.id

  private_service_connection {
    name                           = local.storage_private_endpoint_name
    private_connection_resource_id = azurerm_storage_account.redcap.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

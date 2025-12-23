# Virtual Network
resource "azurerm_virtual_network" "redcap_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.redcap.name
  address_space       = var.vnet_address_space

  depends_on = [azurerm_resource_group.redcap]

  lifecycle {
    ignore_changes = [tags]
  }
}

# PrivateLinkSubnet
resource "azurerm_subnet" "private_link" {
  name                 = "PrivateLinkSubnet"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap_vnet.name
  address_prefixes     = [var.private_link_subnet_prefix]

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

# ComputeSubnet
resource "azurerm_subnet" "compute" {
  name                 = "ComputeSubnet"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap_vnet.name
  address_prefixes     = [var.compute_subnet_prefix]

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Web"
  ]
}

# IntegrationSubnet (delegated to App Service)
resource "azurerm_subnet" "integration" {
  name                 = "IntegrationSubnet"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap_vnet.name
  address_prefixes     = [var.integration_subnet_prefix]

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Web"
  ]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# MySQLFlexSubnet (delegated to MySQL Flexible Server)
resource "azurerm_subnet" "mysql_flex" {
  name                 = "MySQLFlexSubnet"
  resource_group_name  = azurerm_resource_group.redcap.name
  virtual_network_name = azurerm_virtual_network.redcap_vnet.name
  address_prefixes     = [var.mysql_flex_subnet_prefix]

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
    }
  }
}

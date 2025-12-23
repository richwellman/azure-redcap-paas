# REDCap Azure Terraform Deployment

This Terraform configuration creates a complete REDCap infrastructure deployment on Azure, including:

- Virtual Network with four subnets (PrivateLink, Compute, Integration, MySQLFlex)
- Azure Blob Storage for REDCap file attachments
- Azure Key Vault for secure credential storage
- MySQL Flexible Server database
- Linux App Service with PHP runtime for REDCap application
- User-Assigned Managed Identity for secure access
- Private endpoints and DNS zones for all services
- VNet integration for secure networking

The configuration replicates the Bicep module functionality from the main deployment and ARM templates.

## Resources Created

### Network Resources (network.tf)

- **Virtual Network**: 192.168.1.0/24 address space
- **PrivateLinkSubnet**: 192.168.1.0/28 - For private endpoints
- **ComputeSubnet**: 192.168.1.16/28 - General compute resources
- **IntegrationSubnet**: 192.168.1.32/28 - Delegated to App Service (Microsoft.Web/serverFarms)
- **MySQLFlexSubnet**: 192.168.1.48/28 - Delegated to MySQL Flexible Server (Microsoft.DBforMySQL/flexibleServers)

### Storage Resources (storage.tf)

- **Storage Account**: StorageV2 with Standard_LRS replication, Hot access tier
- **Blob Container**: "redcap" container for REDCap file attachments
- **Private Endpoint**: For secure blob storage access via PrivateLinkSubnet
- **Private DNS Zone**: privatelink.blob.core.windows.net for private endpoint DNS resolution
- **VNet Link**: Links private DNS zone to the virtual network

### Key Vault Resources (keyvault.tf)

- **Key Vault**: Standard SKU with RBAC authorization, soft delete, and purge protection
- **Key Vault Secrets**: Stores credentials (REDCap community, SQL admin, storage key)
- **Private Endpoint**: For secure Key Vault access via PrivateLinkSubnet
- **Private DNS Zone**: privatelink.vaultcore.azure.net for private endpoint DNS resolution
- **VNet Link**: Links private DNS zone to the virtual network

### Database Resources (database.tf)

- **MySQL Flexible Server**: Burstable SKU (Standard_B1s) with MySQL 8.0.21
- **MySQL Database**: "redcapdb" with utf8 charset and utf8_general_ci collation (REDCap requirement)
- **Private Endpoint**: For secure MySQL access via PrivateLinkSubnet
- **Private DNS Zone**: privatelink.mysql.database.azure.com for private endpoint DNS resolution
- **VNet Link**: Links private DNS zone to the virtual network
- **Server Configuration**: Disables sql_generate_invisible_primary_key parameter (REDCap requirement)

### Web App Resources (webapp.tf)

- **User-Assigned Managed Identity (UAMI)**: For Key Vault access and Azure resource authentication
- **App Service Plan**: Premium v3 SKU (P0v3) for Linux
- **Linux App Service**: PHP 8.4 runtime with REDCap application
- **VNet Integration**: Connected to IntegrationSubnet for outbound traffic
- **Private Endpoint**: For secure App Service access via PrivateLinkSubnet
- **Private DNS Zone**: privatelink.azurewebsites.net for private endpoint DNS resolution
- **VNet Link**: Links private DNS zone to the virtual network
- **Source Control**: External Git integration for deployment scripts

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and authenticated (`az login`)
- Azure subscription with appropriate permissions
- Appropriate RBAC permissions to create resource groups and resources

## Usage

1. **Copy the example variables files**:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp secrets.tfvars.example secrets.tfvars
   ```

2. **Edit terraform.tfvars** with your subscription ID and non-sensitive configuration values

3. **Edit secrets.tfvars** with sensitive values (passwords, credentials)

   **Important**: The `secrets.tfvars` file is excluded from git via `.gitignore` to prevent accidentally committing secrets.

4. **Initialize Terraform**:

   ```bash
   terraform init
   ```

5. **Review the plan**:

   ```bash
   terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"
   ```

6. **Apply the configuration**:

   ```bash
   terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
   ```

### Alternative: Using Environment Variables

Instead of using `secrets.tfvars`, you can set sensitive values via environment variables:

```bash
export TF_VAR_redcap_community_username="your-username"
export TF_VAR_redcap_community_password="your-password"
export TF_VAR_sql_password="your-sql-password"

terraform apply -var-file="terraform.tfvars"
```

## Service Endpoints

Each subnet is configured with the following service endpoints:

- **PrivateLinkSubnet**: Microsoft.KeyVault, Microsoft.Storage
- **ComputeSubnet**: Microsoft.KeyVault, Microsoft.Storage, Microsoft.Web
- **IntegrationSubnet**: Microsoft.KeyVault, Microsoft.Storage, Microsoft.Web
- **MySQLFlexSubnet**: Microsoft.KeyVault, Microsoft.Storage

## Subnet Delegations

- **IntegrationSubnet**: Delegated to `Microsoft.Web/serverFarms` for App Service VNet integration
- **MySQLFlexSubnet**: Delegated to `Microsoft.DBforMySQL/flexibleServers` for MySQL Flexible Server

## Outputs

The configuration outputs the following values for use in other deployments:

### Network Outputs

- `vnet_id` - Virtual network resource ID
- `vnet_name` - Virtual network name
- `private_link_subnet_id` - PrivateLinkSubnet resource ID
- `compute_subnet_id` - ComputeSubnet resource ID
- `integration_subnet_id` - IntegrationSubnet resource ID
- `mysql_flex_subnet_id` - MySQLFlexSubnet resource ID

### Storage Outputs

- `storage_account_id` - Storage account resource ID
- `storage_account_name` - Storage account name
- `storage_account_primary_blob_endpoint` - Primary blob endpoint URL
- `storage_account_primary_access_key` - Primary access key (sensitive)
- `blob_container_name` - Name of the REDCap blob container
- `storage_private_endpoint_id` - Storage private endpoint resource ID
- `blob_private_dns_zone_id` - Blob private DNS zone resource ID

### Key Vault Outputs

- `key_vault_id` - Key Vault resource ID
- `key_vault_name` - Key Vault name
- `key_vault_uri` - Key Vault URI
- `keyvault_private_endpoint_id` - Key Vault private endpoint resource ID
- `keyvault_private_dns_zone_id` - Key Vault private DNS zone resource ID
- `key_vault_tenant_id` - Tenant ID associated with the Key Vault

### Database Outputs

- `mysql_server_id` - MySQL Flexible Server resource ID
- `mysql_server_name` - MySQL Flexible Server name
- `mysql_server_fqdn` - MySQL Flexible Server fully qualified domain name
- `mysql_database_name` - MySQL database name
- `mysql_admin_username` - MySQL administrator username (sensitive)
- `mysql_private_endpoint_id` - MySQL private endpoint resource ID
- `mysql_private_dns_zone_id` - MySQL private DNS zone resource ID

### Web App Outputs

- `uami_id` - User-Assigned Managed Identity resource ID
- `uami_principal_id` - UAMI principal ID (for RBAC assignments)
- `uami_client_id` - UAMI client ID
- `app_service_plan_id` - App Service Plan resource ID
- `app_service_id` - App Service resource ID
- `app_service_name` - App Service name
- `app_service_default_hostname` - App Service default hostname
- `app_service_url` - App Service HTTPS URL
- `app_service_outbound_ip_addresses` - App Service outbound IP addresses
- `app_service_private_endpoint_id` - App Service private endpoint resource ID
- `webapp_private_dns_zone_id` - App Service private DNS zone resource ID

## Storage Security Features

The storage account is configured with the following security settings:

- **Public Network Access**: Disabled - only accessible via private endpoint
- **Minimum TLS Version**: TLS 1.2
- **Public Blob Access**: Disabled
- **HTTPS Only**: Required for all connections
- **Encryption**: Enabled for blob and file services using Microsoft-managed keys
- **Cross-Tenant Replication**: Disabled

## Key Vault Security Features

The Key Vault is configured with the following security settings:

- **Public Network Access**: Disabled - only accessible via private endpoint
- **RBAC Authorization**: Enabled for granular access control
- **Soft Delete**: Enabled with 7-day retention period
- **Purge Protection**: Enabled to prevent permanent deletion during retention period
- **Network ACLs**: Default action set to Deny, with bypass for Azure Services
- **Enabled for Deployment**: Allows Azure to retrieve secrets during VM deployment
- **Enabled for Template Deployment**: Allows ARM templates to retrieve secrets
- **Tenant ID**: Automatically set from current Azure client configuration

### Key Vault Secrets

The following secrets are stored in Key Vault:

- `redcapCommunityUsername` - REDCap community site username
- `redcapCommunityPassword` - REDCap community site password
- `sqlAdminName` - MySQL admin username
- `sqlPassword` - MySQL admin password
- `storageKey` - Storage account primary access key (automatically populated)

**Note**: Secrets with sensitive values should be provided via environment variables (e.g., `TF_VAR_sql_password`) or entered during `terraform apply` to avoid storing them in plain text.

## MySQL Database Configuration

The MySQL Flexible Server is configured with the following settings:

- **Public Network Access**: Disabled - only accessible via private endpoint
- **Version**: MySQL 8.0.21
- **SKU**: Standard_B1s (Burstable tier) - suitable for development/small production workloads
- **Storage**: 20GB with auto-grow enabled, 396 IOPS
- **Backup Retention**: 7 days
- **Geo-Redundant Backup**: Disabled (can be enabled by setting variable)
- **High Availability**: Disabled (can be enabled by setting variable)

### REDCap Database Requirements

The database is configured with specific requirements for REDCap:

- **Character Set**: `utf8` (required by REDCap)
- **Collation**: `utf8_general_ci` (required by REDCap)
- **Invisible Primary Key**: Disabled via `sql_generate_invisible_primary_key = OFF` configuration
- **Database Name**: `redcapdb`

### MySQL Connection

The MySQL server is accessible via private endpoint with FQDN output as `mysql_server_fqdn`. Connection details:

- **Host**: Use the FQDN from `mysql_server_fqdn` output
- **Database**: `redcapdb`
- **Username**: Value from `sql_admin_name` variable (default: `sqladmin`)
- **Password**: Stored in Key Vault secret `sqlPassword`
- **Port**: 3306 (default MySQL port)

## App Service Configuration

The App Service is configured with the following settings:

- **Public Network Access**: Disabled - only accessible via private endpoint
- **SKU**: Premium v3 (P0v3) - suitable for production workloads
- **OS**: Linux
- **Runtime**: PHP 8.4
- **Always On**: Enabled
- **HTTP/2**: Enabled
- **Minimum TLS**: 1.2
- **HTTPS Only**: Required
- **VNet Integration**: Connected to IntegrationSubnet for outbound connectivity
- **Managed Identity**: User-Assigned Managed Identity for Key Vault access

### REDCap Application Settings

The App Service is configured with application settings that connect to all integrated services:

- **Database Connection**: References MySQL FQDN, database name, and credentials from Key Vault
- **Storage Account**: References storage account name, key (from Key Vault), and container name
- **REDCap Community**: References community credentials from Key Vault for downloading REDCap
- **SMTP Configuration**: Configurable SMTP server settings for email notifications
- **Source Control**: GitHub repository URL and branch for deployment scripts

### Key Vault Integration

All sensitive credentials are stored in Key Vault and referenced using the `@Microsoft.KeyVault()` syntax:

- `DB_USERNAME` → Key Vault secret `sqlAdminName`
- `DB_PASSWORD` → Key Vault secret `sqlPassword`
- `STORAGE_ACCOUNT_KEY` → Key Vault secret `storageKey`
- `REDCAP_COMMUNITY_USERNAME` → Key Vault secret `redcapCommunityUsername`
- `REDCAP_COMMUNITY_PASSWORD` → Key Vault secret `redcapCommunityPassword`

The User-Assigned Managed Identity is configured as the Key Vault reference identity, allowing the App Service to retrieve secrets securely.

### Deployment Process

The App Service uses External Git integration to pull deployment scripts from the specified repository:

1. **Source Repository**: Default is Microsoft's azure-redcap-paas repository (configurable)
2. **Deployment Scripts**: Located in `scripts/bash/` directory
3. **Startup Command**: `/home/startup.sh` runs on container startup to install sendmail, cron, and configure REDCap cron job

## RBAC Permissions

After deploying the resources, you'll need to assign RBAC roles for proper access control:

### Key Vault Access

```bash
# Assign Key Vault Administrator role to your user (for managing Key Vault)
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee <your-user-object-id> \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-redcapkeyvault-prod-002/providers/Microsoft.KeyVault/vaults/kv-redcapv4h7-prod-002

# Assign Key Vault Secrets User role to UAMI (for App Service to read secrets)
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $(terraform output -raw uami_principal_id) \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-redcapkeyvault-prod-002/providers/Microsoft.KeyVault/vaults/kv-redcapv4h7-prod-002
```

### Storage Account Access (Optional)

If using managed identity for storage access instead of access keys:

```bash
# Assign Storage Blob Data Contributor role to UAMI
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee $(terraform output -raw uami_principal_id) \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-redcapstorage-prod-002/providers/Microsoft.Storage/storageAccounts/stredcapz5uoprod002
```

## Post-Deployment Steps

After the Terraform deployment completes successfully:

1. **Assign RBAC Roles**: Run the RBAC commands above to grant Key Vault access to the UAMI
2. **Verify App Service**: Check that the App Service is running and can access Key Vault secrets
3. **Run REDCap Installation**: SSH into the App Service and run the REDCap installation script:

   ```bash
   # SSH to App Service (requires Azure CLI)
   az webapp ssh --resource-group rg-redcapweb-prod-002 --name app-redcapbgk7-prod-002

   # Run installation script
   bash ./site/repository/scripts/bash/install.sh
   ```

4. **Restart App Service**: After installation, restart the App Service to load updated settings
5. **Verify Configuration**: Access the REDCap Configuration Check page to verify all settings are green

## Notes

- Private endpoint network policies are disabled on all subnets to support private endpoints
- The configuration replicates the Bicep modules in the main deployment for network, storage, Key Vault, database, and web app resources
- All resources are tagged according to the REDCap tagging strategy
- Resource names must be globally unique:
  - Storage account: 3-24 lowercase alphanumeric characters
  - Key Vault: 3-24 characters
  - MySQL server: 3-63 lowercase characters
  - App Service: globally unique DNS name
- The `storageKey` secret is automatically populated with the storage account's primary access key
- All credentials are stored in Key Vault and referenced by the App Service using `@Microsoft.KeyVault()` syntax
- The MySQL server and App Service use private endpoint connectivity and are not accessible from the public internet
- REDCap-specific database configuration (charset, collation, invisible primary key setting) is automatically applied
- The App Service uses VNet integration for outbound traffic and private endpoint for inbound access
- Source control integration pulls deployment scripts from the configured GitHub repository

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name (test, demo, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["test", "demo", "prod"], var.environment)
    error_message = "Environment must be test, demo, or prod."
  }
}

variable "sequence" {
  description = "Deployment sequence number (e.g., 001, 002)"
  type        = string
  default     = "001"
  validation {
    condition     = can(regex("^\\d{3}$", var.sequence))
    error_message = "Sequence must be a 3-digit number (e.g., 001, 002)."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group for all REDCap resources"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralus"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-redcapz6fr-prod-002"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "private_link_subnet_prefix" {
  description = "Address prefix for PrivateLinkSubnet"
  type        = string
  default     = "192.168.1.0/28"
}

variable "compute_subnet_prefix" {
  description = "Address prefix for ComputeSubnet"
  type        = string
  default     = "192.168.1.16/28"
}

variable "integration_subnet_prefix" {
  description = "Address prefix for IntegrationSubnet"
  type        = string
  default     = "192.168.1.32/28"
}

variable "mysql_flex_subnet_prefix" {
  description = "Address prefix for MySQLFlexSubnet"
  type        = string
  default     = "192.168.1.48/28"
}



variable "redcap_community_username" {
  description = "REDCap community site username (stored in Key Vault)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redcap_community_password" {
  description = "REDCap community site password (stored in Key Vault)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sql_admin_name" {
  description = "SQL admin username (stored in Key Vault)"
  type        = string
  default     = "sqladmin"
}

variable "sql_password" {
  description = "SQL admin password (stored in Key Vault)"
  type        = string
  default     = ""
  sensitive   = true
}


variable "mysql_sku_name" {
  description = "MySQL Flexible Server SKU name"
  type        = string
  default     = "GP_Standard_D2ds_v4"
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.4"
}

variable "mysql_storage_size_gb" {
  description = "MySQL storage size in GB"
  type        = number
  default     = 20
}

variable "mysql_storage_iops" {
  description = "MySQL storage IOPS"
  type        = number
  default     = 396
}

variable "mysql_backup_retention_days" {
  description = "MySQL backup retention in days"
  type        = number
  default     = 7
}

variable "mysql_geo_redundant_backup" {
  description = "Enable geo-redundant backup for MySQL"
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.mysql_geo_redundant_backup)
    error_message = "MySQL geo-redundant backup must be Enabled or Disabled."
  }
}

variable "mysql_database_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "redcapdb"
}

variable "mysql_database_charset" {
  description = "MySQL database character set (required for REDCap)"
  type        = string
  default     = "utf8"
}

variable "mysql_database_collation" {
  description = "MySQL database collation (required for REDCap)"
  type        = string
  default     = "utf8_general_ci"
}


variable "app_service_sku_name" {
  description = "App Service Plan SKU name"
  type        = string
  default     = "P0v3"
}

variable "app_service_php_version" {
  description = "PHP version for the App Service"
  type        = string
  default     = "8.4"
}

variable "app_service_startup_command" {
  description = "Startup command for the App Service"
  type        = string
  default     = "/home/startup.sh"
}

variable "redcap_zip_url" {
  description = "Direct URL to REDCap zip file (optional)"
  type        = string
  default     = "https://stthcriblpov.blob.core.windows.net/redcap/redcap15.5.0.zip"
  sensitive   = true
}

variable "scm_repo_url" {
  description = "Source control repository URL"
  type        = string
  default     = "https://github.com/richwellman/azure-redcap-paas"
}

variable "scm_repo_branch" {
  description = "Source control repository branch"
  type        = string
  default     = "main"
}

variable "smtp_fqdn" {
  description = "SMTP server FQDN or IP address"
  type        = string
  default     = ""
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = string
  default     = "587"
}

variable "smtp_from_email_address" {
  description = "SMTP from email address"
  type        = string
  default     = ""
}

variable "enable_keyvault_public_access" {
  description = "Enable public network access to Key Vault (required for Terraform deployment unless running from VNet)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Application    = "Redcap"
    DR             = "none"
    ServiceClass   = "P3"
    Owner          = "Rich Wellman"
    Support        = "PE-Engineering"
    Classification = "P3"
    workloadType   = "networking"
    cust_1         = "User Data"
    cust_2         = "User Data"
    cust_3         = "User Data"
    cust_4         = "User Data"
  }
}

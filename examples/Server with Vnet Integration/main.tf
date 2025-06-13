# MySQL Database with VNet Integration Example
# This example demonstrates how to deploy Azure MySQL Flexible Server with VNet integration
# It supports two modes: using existing VNet/subnet or creating new ones

# Local values for resource naming and configuration
locals {
  # Resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = merge({
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "MySQL-VNet-Integration"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }, var.additional_tags)
  
  # MySQL server configuration
  mysql_server_name = "${local.resource_prefix}-mysql-server"
  resource_group_name = "${local.resource_prefix}-mysql-rg"
  
  # VNet configuration based on integration mode
  vnet_name = var.vnet_integration_mode == "module" ? "${local.resource_prefix}-mysql-vnet" : null
  subnet_name = var.vnet_integration_mode == "module" ? "${local.resource_prefix}-mysql-subnet" : null
  
  # High availability configuration
  ha_mode = var.enable_high_availability ? var.high_availability_mode : "Disabled"
}

# Example 1: MySQL with Module-Created VNet (Default)
module "mysql_with_new_vnet" {
  count  = var.vnet_integration_mode == "module" ? 1 : 0
  source = "../../"  # Points to the MySQL Database module
  
  # Resource Group Configuration
  resource_group_name = local.resource_group_name
  location           = var.location
  
  # MySQL Server Configuration
  mysql_server_name     = local.mysql_server_name
  mysql_admin_username  = var.mysql_admin_username
  mysql_admin_password  = var.mysql_admin_password
  mysql_server_sku      = var.mysql_server_sku
  mysql_server_version  = "8.0"
  mysql_server_size_in_gb = var.storage_size_gb
  
  # High Availability Configuration
  mysql_server_high_availability_mode = local.ha_mode
  msql_serverzone = 1
  
  # Backup Configuration
  mysql_server_backup_retention_days = var.backup_retention_days
  enable_geo_redundant_backup       = var.enable_geo_redundant_backup
  
  # VNet Integration - Module Creates VNet/Subnet
  enable_vnet_integration        = true
  mysql_vnet_name               = local.vnet_name
  mysql_vnet_address_space      = var.vnet_address_space
  mysql_subnet_name             = local.subnet_name
  mysql_subnet_address_prefixes = var.subnet_address_prefix
  mysql_subnet_service_endpoints = ["Microsoft.Storage"]
  
  # Private DNS Zone (optional)
  private_dns_zone_id = var.existing_private_dns_zone_id
  
  # Multiple Databases Configuration
  mysql_databases = var.databases
  
  # Managed Identity
  mysql_server_identity_type = "SystemAssigned"
  
  # Maintenance Window (Sunday 2:00 AM)
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
  
  # Tags
  tags = local.common_tags
}

# Example 2: MySQL with Existing VNet/Subnet
module "mysql_with_existing_vnet" {
  count  = var.vnet_integration_mode == "external" ? 1 : 0
  source = "../../"  # Points to the MySQL Database module
  
  # Resource Group Configuration
  resource_group_name = local.resource_group_name
  location           = var.location
  
  # MySQL Server Configuration
  mysql_server_name     = local.mysql_server_name
  mysql_admin_username  = var.mysql_admin_username
  mysql_admin_password  = var.mysql_admin_password
  mysql_server_sku      = var.mysql_server_sku
  mysql_server_version  = "8.0"
  mysql_server_size_in_gb = var.storage_size_gb
  
  # High Availability Configuration
  mysql_server_high_availability_mode = local.ha_mode
  msql_serverzone = 1
  
  # Backup Configuration
  mysql_server_backup_retention_days = var.backup_retention_days
  enable_geo_redundant_backup       = var.enable_geo_redundant_backup
  
  # VNet Integration - Use Existing Subnet
  enable_vnet_integration = true
  delegated_subnet_id     = var.existing_delegated_subnet_id
  private_dns_zone_id     = var.existing_private_dns_zone_id
  
  # Multiple Databases Configuration
  mysql_databases = var.databases
  
  # Managed Identity
  mysql_server_identity_type = "SystemAssigned"
  
  # Maintenance Window (Sunday 2:00 AM)
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
  
  # Tags
  tags = local.common_tags
}

# Data source to get the deployed module for outputs
locals {
  deployed_module = var.vnet_integration_mode == "module" ? module.mysql_with_new_vnet[0] : module.mysql_with_existing_vnet[0]
}
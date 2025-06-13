# MySQL Database without VNet Integration Example
# This example demonstrates how to deploy Azure MySQL Flexible Server with public access
# using firewall rules for security instead of VNet integration

# Local values for resource naming and configuration
locals {
  # Resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = merge({
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "MySQL-Public-Access"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }, var.additional_tags)
  
  # MySQL server configuration
  mysql_server_name = "${local.resource_prefix}-mysql-public"
  resource_group_name = "${local.resource_prefix}-mysql-public-rg"
  
  # High availability configuration
  ha_mode = var.enable_high_availability ? var.high_availability_mode : "Disabled"
  
  # Identity configuration
  identity_type = var.enable_system_identity ? "SystemAssigned" : "None"
}

# MySQL Server with Public Access
module "mysql_public_server" {
  source = "../../"  # Points to the MySQL Database module
  
  # Resource Group Configuration
  resource_group_name = local.resource_group_name
  location           = var.location
  
  # MySQL Server Configuration
  mysql_server_name     = local.mysql_server_name
  mysql_admin_username  = var.mysql_admin_username
  mysql_admin_password  = var.mysql_admin_password
  mysql_server_sku      = var.mysql_server_sku
  mysql_server_version  = var.mysql_server_version
  mysql_server_size_in_gb = var.storage_size_gb
  
  # High Availability Configuration
  mysql_server_high_availability_mode = local.ha_mode
  msql_serverzone = var.mysql_server_zone
  
  # Backup Configuration
  mysql_server_backup_retention_days = var.backup_retention_days
  enable_geo_redundant_backup       = var.enable_geo_redundant_backup
  
  # VNet Integration - Disabled for public access
  enable_vnet_integration = false
  
  # Multiple Databases Configuration
  mysql_databases = var.databases
  
  # Managed Identity
  mysql_server_identity_type = local.identity_type
  
  # No maintenance window configuration (as requested)
  
  # Tags
  tags = local.common_tags
}

# Multiple Firewall Rules for Different IP Ranges
resource "azurerm_mysql_flexible_server_firewall_rule" "custom_rules" {
  for_each = var.firewall_rules
  
  name                = each.key
  resource_group_name = local.resource_group_name
  server_name         = module.mysql_public_server.mysql_server_name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
  
  depends_on = [module.mysql_public_server]
}

# Azure Services Access Rule (if enabled)
resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  count = var.allow_azure_services ? 1 : 0
  
  name                = "AllowAzureServices"
  resource_group_name = local.resource_group_name
  server_name         = module.mysql_public_server.mysql_server_name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  
  depends_on = [module.mysql_public_server]
}

# Data source to get resource group information
data "azurerm_resource_group" "mysql_rg" {
  name = local.resource_group_name
  depends_on = [module.mysql_public_server]
}
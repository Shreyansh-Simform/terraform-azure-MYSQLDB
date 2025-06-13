# MySQL Database with VNet Integration Example - Outputs

# Resource Group Information
output "resource_group_name" {
  description = "Name of the resource group created"
  value       = local.deployed_module.resource_group_id != null ? local.resource_group_name : null
}

output "resource_group_id" {
  description = "ID of the resource group created"
  value       = local.deployed_module.resource_group_id
}

# MySQL Server Information
output "mysql_server_id" {
  description = "ID of the MySQL Flexible Server"
  value       = local.deployed_module.mysql_server_id
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL Flexible Server"
  value       = local.deployed_module.mysql_server_fqdn
}

output "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  value       = local.mysql_server_name
}

# Database Information
output "mysql_databases" {
  description = "Information about created databases"
  value       = local.deployed_module.mysql_databases
}

output "database_names" {
  description = "List of database names created"
  value       = keys(var.databases)
}

# Network Information
output "vnet_integration_enabled" {
  description = "Whether VNet integration is enabled"
  value       = true
}

output "vnet_integration_mode" {
  description = "VNet integration mode used"
  value       = var.vnet_integration_mode
}

output "mysql_vnet_id" {
  description = "ID of the VNet created by the module (if applicable)"
  value       = local.deployed_module.mysql_vnet_id
}

output "mysql_subnet_id" {
  description = "ID of the subnet created by the module (if applicable)"
  value       = local.deployed_module.mysql_subnet_id
}

output "delegated_subnet_id_used" {
  description = "ID of the delegated subnet actually used by MySQL server"
  value       = local.deployed_module.delegated_subnet_id_used
}

# Connection Information
output "mysql_connection_string" {
  description = "MySQL connection string template (password needs to be replaced)"
  value       = local.deployed_module.mysql_connection_string
  sensitive   = true
}

output "connection_guide" {
  description = "Guide for connecting to the MySQL server"
  value = {
    server_fqdn = local.deployed_module.mysql_server_fqdn
    port        = 3306
    username    = var.mysql_admin_username
    note        = "Use the FQDN to connect from applications within the VNet. Password authentication or certificate-based authentication is supported."
  }
}

# Security Information
output "mysql_server_identity" {
  description = "Managed identity information for the MySQL server"
  value = {
    type         = local.deployed_module.mysql_server_identity.type
    principal_id = local.deployed_module.mysql_server_identity.principal_id
    tenant_id    = local.deployed_module.mysql_server_identity.tenant_id
  }
}

# High Availability Information
output "high_availability_info" {
  description = "High availability configuration"
  value = {
    enabled = var.enable_high_availability
    mode    = local.ha_mode
    details = local.deployed_module.mysql_server_high_availability
  }
}

# Configuration Summary
output "deployment_summary" {
  description = "Summary of the MySQL deployment configuration"
  value = {
    environment     = var.environment
    project_name    = var.project_name
    location        = var.location
    server_sku      = var.mysql_server_sku
    storage_size_gb = var.storage_size_gb
    vnet_mode       = var.vnet_integration_mode
    ha_enabled      = var.enable_high_availability
    database_count  = length(var.databases)
    backup_retention_days = var.backup_retention_days
    geo_redundant_backup  = var.enable_geo_redundant_backup
  }
}
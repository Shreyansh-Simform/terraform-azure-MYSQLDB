# MySQL Database without VNet Integration Example - Outputs

# Resource Group Information
output "resource_group_name" {
  description = "Name of the resource group created"
  value       = data.azurerm_resource_group.mysql_rg.name
}

output "resource_group_id" {
  description = "ID of the resource group created"
  value       = module.mysql_public_server.resource_group_id
}

# MySQL Server Information
output "mysql_server_id" {
  description = "ID of the MySQL Flexible Server"
  value       = module.mysql_public_server.mysql_server_id
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL Flexible Server (public endpoint)"
  value       = module.mysql_public_server.mysql_server_fqdn
}

output "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  value       = local.mysql_server_name
}

# Database Information
output "mysql_databases" {
  description = "Information about created databases"
  value       = module.mysql_public_server.mysql_databases
}

output "database_names" {
  description = "List of database names created"
  value       = keys(var.databases)
}

# Firewall Rules Information
output "firewall_rules_created" {
  description = "Map of firewall rules created"
  value = {
    custom_rules = {
      for rule_name, rule in azurerm_mysql_flexible_server_firewall_rule.custom_rules : rule_name => {
        start_ip = rule.start_ip_address
        end_ip   = rule.end_ip_address
      }
    }
    azure_services_allowed = var.allow_azure_services
  }
}

output "firewall_rules_summary" {
  description = "Summary of firewall configuration"
  value = {
    total_custom_rules     = length(var.firewall_rules)
    azure_services_enabled = var.allow_azure_services
    rule_names            = keys(var.firewall_rules)
  }
}

# Connection Information
output "mysql_connection_string" {
  description = "MySQL connection string template (password needs to be replaced)"
  value       = module.mysql_public_server.mysql_connection_string
  sensitive   = true
}

output "connection_guide" {
  description = "Guide for connecting to the MySQL server"
  value = {
    server_fqdn = module.mysql_public_server.mysql_server_fqdn
    port        = 3306
    username    = var.mysql_admin_username
    access_type = "Public"
    note        = "Connect from allowed IP ranges defined in firewall rules. SSL/TLS connection is required."
  }
}

# Security Information
output "mysql_server_identity" {
  description = "Managed identity information for the MySQL server"
  value = var.enable_system_identity ? {
    type         = module.mysql_public_server.mysql_server_identity.type
    principal_id = module.mysql_public_server.mysql_server_identity.principal_id
    tenant_id    = module.mysql_public_server.mysql_server_identity.tenant_id
  } : null
}

output "security_configuration" {
  description = "Security configuration summary"
  value = {
    public_access_enabled = true
    vnet_integration     = false
    firewall_rules_count = length(var.firewall_rules)
    system_identity      = var.enable_system_identity
    ssl_enforcement      = true
  }
}

# High Availability Information
output "high_availability_info" {
  description = "High availability configuration"
  value = {
    enabled = var.enable_high_availability
    mode    = local.ha_mode
    details = var.enable_high_availability ? module.mysql_public_server.mysql_server_high_availability : null
  }
}

# Storage Information
output "storage_configuration" {
  description = "Storage configuration details"
  value = {
    size_gb               = var.storage_size_gb
    storage_details       = module.mysql_public_server.mysql_server_storage_info
    backup_retention_days = var.backup_retention_days
    geo_redundant_backup  = var.enable_geo_redundant_backup
  }
}

# Configuration Summary
output "deployment_summary" {
  description = "Summary of the MySQL deployment configuration"
  value = {
    environment          = var.environment
    project_name         = var.project_name
    location             = var.location
    server_sku           = var.mysql_server_sku
    server_version       = var.mysql_server_version
    storage_size_gb      = var.storage_size_gb
    access_type          = "Public"
    ha_enabled           = var.enable_high_availability
    database_count       = length(var.databases)
    firewall_rules_count = length(var.firewall_rules)
    azure_services_access = var.allow_azure_services
    backup_retention_days = var.backup_retention_days
    geo_redundant_backup  = var.enable_geo_redundant_backup
  }
}
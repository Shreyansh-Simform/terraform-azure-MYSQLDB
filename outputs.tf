# Essential Resource Group Outputs
output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

# Essential MySQL Server Outputs
output "mysql_server_id" {
  description = "The ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.id
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_server_identity" {
  description = "Identity configuration of the MySQL Flexible Server"
  value = {
    type         = azurerm_mysql_flexible_server.mysql.identity[0].type
    identity_ids = azurerm_mysql_flexible_server.mysql.identity[0].identity_ids
  }
}

output "mysql_server_storage_info" {
  description = "Storage configuration of the MySQL Flexible Server"
  value = {
    size_gb                  = azurerm_mysql_flexible_server.mysql.storage[0].size_gb
    auto_grow_enabled        = azurerm_mysql_flexible_server.mysql.storage[0].auto_grow_enabled
    io_scaling_enabled       = azurerm_mysql_flexible_server.mysql.storage[0].io_scaling_enabled
    iops                     = azurerm_mysql_flexible_server.mysql.storage[0].iops
  }
}

output "mysql_server_high_availability" {
  description = "High availability configuration of the MySQL Flexible Server"
  value = {
    mode                      = azurerm_mysql_flexible_server.mysql.high_availability[0].mode
    standby_availability_zone = azurerm_mysql_flexible_server.mysql.high_availability[0].standby_availability_zone
  }
}

# Database Outputs
output "mysql_databases" {
  description = "Map of MySQL databases with their details"
  value = {
    for db_name, db in azurerm_mysql_flexible_database.databases : db_name => {
      id        = db.id
      name      = db.name
      charset   = db.charset
      collation = db.collation
    }
  }
}

# VNet Integration Outputs (only if created by module)
output "mysql_vnet_id" {
  description = "The ID of the VNet created for MySQL (if created by module)"
  value       = length(azurerm_virtual_network.vnet) > 0 ? azurerm_virtual_network.vnet[0].id : null
}

output "mysql_subnet_id" {
  description = "The ID of the subnet created for MySQL (if created by module)"
  value       = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet[0].id : null
}

output "delegated_subnet_id_used" {
  description = "The actual delegated subnet ID used by the MySQL server"
  value       = azurerm_mysql_flexible_server.mysql.delegated_subnet_id
}

# Firewall Rule Outputs (only if created)
output "firewall_rule_id" {
  description = "The ID of the firewall rule (if created)"
  value       = var.firewall_rule_name != null ? azurerm_mysql_flexible_server_firewall_rule.allow_all.id : null
}

# Connection Information
output "mysql_connection_string" {
  description = "MySQL connection string template"
  value       = "mysql://${azurerm_mysql_flexible_server.mysql.administrator_login}:<password>@${azurerm_mysql_flexible_server.mysql.fqdn}:3306/"
  sensitive   = true
}
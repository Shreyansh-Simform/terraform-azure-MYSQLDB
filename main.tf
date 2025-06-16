# This Terraform module creates an Azure MySQL Flexible Server and a database within it.
# It includes optional features like VNet integration, firewall rules, and high availability.
# It is designed to be reusable and can be customized with variables.

# Resource Group Definition for MySQL Database
resource "azurerm_resource_group" "rg" {
  name     = var.sql_resource_group_name
  location = var.sql_location
}

# Optional: VNet and Subnet (for private access)
# These resources are created optionally to provide flexibility:
# - Users can create their own VNet/Subnet infrastructure externally and provide delegated_subnet_id
# - OR users can let this module create the VNet/Subnet for them when VNet integration is enabled
# - OR users can deploy MySQL without VNet integration (public access with firewall rules)
resource "azurerm_virtual_network" "vnet" {
  name                = var.mysql_vnet_name
  address_space       = var.mysql_vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  
  # Only create if VNet integration is enabled AND VNet name/address space are provided
  # This allows users to either use their own VNet (by providing delegated_subnet_id) 
  # or let the module create one for them
  count = var.enable_vnet_integration && var.mysql_vnet_name != null && var.mysql_vnet_address_space != null ? 1 : 0
}

resource "azurerm_subnet" "subnet" {
  name                 = var.mysql_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.mysql_subnet_address_prefixes
  service_endpoints    = var.mysql_subnet_service_endpoints
  
  # Delegate subnet to MySQL Flexible Server service for VNet integration
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
  
  # Only create if VNet integration is enabled AND subnet parameters are provided
  # This subnet will be used for MySQL VNet integration when created by this module
  count = var.enable_vnet_integration && var.mysql_subnet_name != null && var.mysql_subnet_address_prefixes != null && length(azurerm_virtual_network.vnet) > 0 ? 1 : 0
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = var.mysql_server_name
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  sku_name               = var.mysql_server_sku   
  version                = var.mysql_server_version
  storage {
   size_gb = var.mysql_server_size_in_gb # Minimum size for MySQL Flexible Server is 20 GiB
  }
  backup_retention_days  = var.mysql_server_backup_retention_days
  geo_redundant_backup_enabled = var.enable_geo_redundant_backup

  zone                   = var.msql_serverzone
  high_availability {
    mode = var.mysql_server_high_availability_mode # "ZoneRedundant" or "SameZone", "Disabled"
  }

  identity {
    type = var.mysql_server_identity_type
    identity_ids = var.mysql_server_identity_ids
  }

  maintenance_window {
    day_of_week  = var.maintenance_window.day_of_week
    start_hour   = var.maintenance_window.start_hour
    start_minute = var.maintenance_window.start_minute
  }

  tags = var.tags

  # Conditional VNet integration - supports both module-created and externally-provided subnets
  delegated_subnet_id = var.enable_vnet_integration ? (
    var.delegated_subnet_id != null ? var.delegated_subnet_id : 
    length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet[0].id : null
  ) : null
  private_dns_zone_id = var.enable_vnet_integration ? var.private_dns_zone_id : null
  create_mode         = var.create_mode

  lifecycle {
    ignore_changes = [administrator_password] # don't replace server on password change
    prevent_destroy =  true
    create_before_destroy = false
  }
}

# MySQL Flexible Databases - Support for multiple databases
resource "azurerm_mysql_flexible_database" "databases" {
  for_each = var.mysql_databases
  
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = each.value.charset
  collation           = each.value.collation

  lifecycle {
    ignore_changes = [charset, collation] # Ignore changes to charset and collation
    prevent_destroy  = true # Prevent accidental deletion
    create_before_destroy = false 
  }
}

# Optional: Firewall rule
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = var.firewall_rule_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = var.firewall_rule_start_ip_address
  end_ip_address      = var.firewall_rule_end_ip_address
    depends_on = [
        azurerm_mysql_flexible_server.mysql
    ]
}

# This file defines the variables used in the MySQL Database module.

# Resource Group Variables

//Location for MySQL Database
variable "location" {
  description = "The Azure region where all resources will be deployed"
  type        = string
}

//Resource Group Name for MySQL Database
variable "resource_group_name" {
    description = "The name of the Azure Resource Group where the MySQL Database will be deployed"
    type        = string    
}

# Virtual Network and Subnet Variables

// Enable VNet Integration for MySQL Database
variable "enable_vnet_integration" {
    description = "Enable VNet integration for the MySQL server. When true, the server will be deployed with VNet integration"
    type        = bool
    default     = false
}

// Virtual Network for MySQL Database
variable "mysql_vnet_name" {
    description = "The name of the Azure Virtual Network for the MySQL Database (Optional)"
    type        = string
    default = null
}

// Virtual Network Address Space for MySQL Database
variable "mysql_vnet_address_space" {
    description = "The address space for the Virtual Network (Optional)"
    type        = list(string)
    default = null
}

// Subnet for MySQL Database
variable "mysql_subnet_name" {
    description = "The name of the subnet within the Virtual Network for the MySQL Database (Optional)"
    type        = string
    default = null
}

// Subnet Address Prefixes for MySQL Database
variable "mysql_subnet_address_prefixes" {
    description = "The address prefixes for the subnet (Optional)"
    type        = list(string)
    default = null
}

// Subnet Service Endpoints for MySQL Database
variable "mysql_subnet_service_endpoints" {
    description = "The service endpoints for the subnet (Optional)"
    type        = list(string)
    default = []
}

#Options for VNet Integration(Optional)

// Delegated Subnet ID for VNet Integration
variable "delegated_subnet_id" {
    description = "The ID of the delegated subnet for VNet integration. Either provide this OR let the module create VNet/Subnet by providing mysql_vnet_name and mysql_subnet_name when enable_vnet_integration is true"
    type        = string
    default     = null
    
    validation {
        condition = var.enable_vnet_integration ? (
            var.delegated_subnet_id != null || 
            (var.mysql_vnet_name != null && var.mysql_subnet_name != null)
        ) : true
        error_message = "When enable_vnet_integration is true, either provide 'delegated_subnet_id' for external subnet OR provide 'mysql_vnet_name' and 'mysql_subnet_name' to let the module create VNet/Subnet."
    }
}

// Private DNS Zone ID for VNet Integration
variable "private_dns_zone_id" {
    description = "The ID of the private DNS zone for VNet integration. Can be null for VNet integration"
    type        = string
    default     = null
}

// Create Mode for MySQL Server
variable "create_mode" {
    description = "The create mode for the MySQL server. Default is 'Default'"
    type        = string
    default     = "Default"
}

# MySQL Flexible Server Variables

// MySQL Server Name
variable "mysql_server_name" {
    description = "The name of the MySQL Flexible Server"
    type        = string
}


// MySQL Server Version
variable "mysql_server_version" {
    description = "The version of the MySQL server (e.g., '8.0', '5.7')"
    type        = string
    default     = "8.0"
}

// MySQL Administrator Credentials
variable "mysql_admin_username" {
    description = "The administrator username for the MySQL server"
    type        = string
    sensitive = true
}

// MySQL Administrator Password
variable "mysql_admin_password" {
    description = "The administrator password for the MySQL server"
    type        = string
    sensitive = true
}

// MySQL Server SKU
variable "mysql_server_sku" {
    description = "The SKU for the MySQL server (e.g., 'Standard_D2ds_v4')"
    type        = string
}

// MySQL Server Size in GB
variable "mysql_server_size_in_gb" {
    description = "The size of the MySQL server in GB"
    type        = number
    default     = 32
}

// MySQL Server Backup Retention Days
variable "mysql_server_backup_retention_days" {
    description = "The number of days to retain backups for the MySQL server"
    type        = number
    default     = 7
}

// Enable Geo-Redundant Backups
variable "enable_geo_redundant_backup" {
    description = "Enable geo-redundant backups for the MySQL server"
    type        = bool
    default     = false
}
 
// MySQL Server Zone
variable "msql_serverzone" {
    description = "The zone for the MySQL server (1, 2, or 3)"
    type        = number
    default     = 1
}

// MySQL Server High Availability Mode
variable "mysql_server_high_availability_mode" {
    description = "The high availability mode for the MySQL server (e.g., 'ZoneRedundant', 'SameZone', 'Disabled')"
    type        = string
    default     = "ZoneRedundant"
    
    validation {
        condition     = contains(["ZoneRedundant", "SameZone", "Disabled"], var.mysql_server_high_availability_mode)
        error_message = "The mysql_server_high_availability_mode must be one of: 'ZoneRedundant', 'SameZone', or 'Disabled'."
    }
}

//  MySQL Server Identity Type
variable "mysql_server_identity_type" {
    description = "The identity type for the MySQL server (e.g., 'SystemAssigned', 'UserAssigned')"
    type        = string
    default     = "SystemAssigned"
    
    validation {
        condition     = contains(["SystemAssigned", "UserAssigned"], var.mysql_server_identity_type)
        error_message = "The mysql_server_identity_type must be either 'SystemAssigned' or 'UserAssigned'."
    }
}

//  MySQL Server User Assigned Managed Identity IDs
variable "mysql_server_identity_ids" {
    description = "List of User Assigned Managed Identity IDs for the MySQL server. Only required when mysql_server_identity_type is 'UserAssigned'"
    type        = list(string)
    default     = []
    
    validation {
        condition = var.mysql_server_identity_type == "UserAssigned" ? length(var.mysql_server_identity_ids) > 0 : length(var.mysql_server_identity_ids) == 0
        error_message = "mysql_server_identity_ids can only have values when mysql_server_identity_type is 'UserAssigned'. When UserAssigned, at least one identity ID must be provided."
    }
}

// Maintenance Window for MySQL Server
variable "maintenance_window" {
    description = "Maintenance window for the MySQL server"
    type = object({
        day_of_week  = number
        start_hour   = number
        start_minute = number
    })
    default = {
        day_of_week  = null  
        start_hour   = null 
        start_minute = null  
    }
}

// Tags for MySQL Server and Resources
variable "tags" {
    description = "A map of tags to assign to the MySQL server and related resources"
    type        = map(string)
    default     = {}
}

# MYSQL Database Variables

// MySQL Databases Map
variable "mysql_databases" {
    description = "Map of MySQL databases to be created on the flexible server. Each database can have custom charset and collation"
    type = map(object({
        charset   = optional(string, "utf8")
        collation = optional(string, "utf8_general_ci")
    }))
    default = {}
    
    validation {
        condition = length(var.mysql_databases) > 0
        error_message = "At least one database must be specified in mysql_databases map."
    }
}

#Server Firewall Rule Variables

// Firewall Rule Name
variable "firewall_rule_name" {
    description = "The name of the firewall rule for the MySQL server"
    type        = string
    default     = null
}

// Firewall Rule Start IP Address
variable "firewall_rule_start_ip_address" {
    description = "The starting IP address for the firewall rule "
    type        = string
    default     = null
}

// Firewall Rule End IP Address
variable "firewall_rule_end_ip_address" {
    description = "The ending IP address for the firewall rule "
    type        = string
    default     = null
}




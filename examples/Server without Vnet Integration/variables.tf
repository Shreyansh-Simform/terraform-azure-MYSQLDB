# MySQL Database without VNet Integration Example - Variables

# Basic Configuration
variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "webapp"
}

# MySQL Configuration
variable "mysql_admin_username" {
  description = "MySQL administrator username"
  type        = string
  default     = "mysqladmin"
  sensitive   = true
}

variable "mysql_admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.mysql_admin_password) >= 8
    error_message = "MySQL admin password must be at least 8 characters long."
  }
}

variable "mysql_server_sku" {
  description = "MySQL server SKU"
  type        = string
  default     = "Standard_B2s"
  
  validation {
    condition = contains([
      "Standard_B1ms", "Standard_B2s", "Standard_B2ms", "Standard_B4ms",
      "Standard_D2ds_v4", "Standard_D4ds_v4", "Standard_E2ds_v4"
    ], var.mysql_server_sku)
    error_message = "MySQL server SKU must be a valid Azure MySQL Flexible Server SKU."
  }
}

variable "mysql_server_version" {
  description = "MySQL server version"
  type        = string
  default     = "8.0"
  
  validation {
    condition     = contains(["5.7", "8.0"], var.mysql_server_version)
    error_message = "MySQL version must be either 5.7 or 8.0."
  }
}

# Database Configuration
variable "databases" {
  description = "Map of databases to create with their configuration"
  type = map(object({
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = {
    "application_db" = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  }
}

# Firewall Configuration
variable "firewall_rules" {
  description = "Map of firewall rules to create"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {
    "office_network" = {
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    }
  }
}

variable "allow_azure_services" {
  description = "Allow Azure services to access the MySQL server"
  type        = bool
  default     = true
}

# High Availability Configuration
variable "enable_high_availability" {
  description = "Enable high availability for MySQL server"
  type        = bool
  default     = false
}

variable "high_availability_mode" {
  description = "High availability mode"
  type        = string
  default     = "Disabled"
  
  validation {
    condition     = contains(["ZoneRedundant", "SameZone", "Disabled"], var.high_availability_mode)
    error_message = "High availability mode must be ZoneRedundant, SameZone, or Disabled."
  }
}

# Backup Configuration
variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

variable "enable_geo_redundant_backup" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

# Storage Configuration
variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 32
  
  validation {
    condition     = var.storage_size_gb >= 20 && var.storage_size_gb <= 16384
    error_message = "Storage size must be between 20 and 16384 GB."
  }
}

variable "mysql_server_zone" {
  description = "Availability zone for the MySQL server"
  type        = number
  default     = 1
  
  validation {
    condition     = var.mysql_server_zone >= 1 && var.mysql_server_zone <= 3
    error_message = "MySQL server zone must be between 1 and 3."
  }
}

# Identity Configuration
variable "enable_system_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = true
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
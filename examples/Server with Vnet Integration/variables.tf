# MySQL Database with VNet Integration Example - Variables

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
  default     = "myapp"
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
  default     = "Standard_D2ds_v4"
  
  validation {
    condition = contains([
      "Standard_B1ms", "Standard_B2s", "Standard_B2ms", "Standard_B4ms",
      "Standard_D2ds_v4", "Standard_D4ds_v4", "Standard_D8ds_v4",
      "Standard_E2ds_v4", "Standard_E4ds_v4", "Standard_E8ds_v4"
    ], var.mysql_server_sku)
    error_message = "MySQL server SKU must be a valid Azure MySQL Flexible Server SKU."
  }
}

# VNet Integration Configuration
variable "vnet_integration_mode" {
  description = "VNet integration mode: 'external' (use existing subnet) or 'module' (create new VNet/subnet)"
  type        = string
  default     = "module"
  
  validation {
    condition     = contains(["external", "module"], var.vnet_integration_mode)
    error_message = "VNet integration mode must be either 'external' or 'module'."
  }
}

variable "existing_delegated_subnet_id" {
  description = "ID of existing delegated subnet (required when vnet_integration_mode is 'external')"
  type        = string
  default     = null
}

variable "existing_private_dns_zone_id" {
  description = "ID of existing private DNS zone (optional)"
  type        = string
  default     = null
}

# Database Configuration
variable "databases" {
  description = "Map of databases to create with their configuration"
  type = map(object({
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = {
    "app_database" = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
    "logging_database" = {
      charset   = "utf8"
      collation = "utf8_general_ci"
    }
  }
}

# High Availability Configuration
variable "enable_high_availability" {
  description = "Enable high availability for MySQL server"
  type        = bool
  default     = true
}

variable "high_availability_mode" {
  description = "High availability mode"
  type        = string
  default     = "ZoneRedundant"
  
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

# Network Configuration (for module-created VNet)
variable "vnet_address_space" {
  description = "Address space for the VNet (used when vnet_integration_mode is 'module')"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the MySQL subnet (used when vnet_integration_mode is 'module')"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Storage Configuration
variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 64
  
  validation {
    condition     = var.storage_size_gb >= 20 && var.storage_size_gb <= 16384
    error_message = "Storage size must be between 20 and 16384 GB."
  }
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
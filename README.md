# Azure MySQL Flexible Server Terraform Module

This Terraform module creates an Azure MySQL Flexible Server with multiple databases and optional VNet integration. It provides flexibility for both public and private deployments with comprehensive configuration options.

## Features

- **MySQL Flexible Server** with configurable SKU, version, and storage
- **Multiple Database Support** with custom charset and collation per database
- **Flexible VNet Integration** - supports three deployment scenarios:
  - Public access with firewall rules
  - Private access using externally provided subnet
  - Private access with module-created VNet/subnet
- **High Availability** with ZoneRedundant, SameZone, or Disabled modes
- **Backup Configuration** with geo-redundant backup options
- **Managed Identity Support** (SystemAssigned or UserAssigned)
- **Maintenance Window Configuration**
- **Firewall Rules** for public access control

## Architecture

The module supports three deployment architectures:

### 1. Public Access (Default)
```
┌─────────────────┐    ┌──────────────────┐
│   Application   │───▶│  MySQL Server    │
│                 │    │  (Public FQDN)   │
└─────────────────┘    └──────────────────┘
                              │
                       ┌──────────────┐
                       │ Firewall     │
                       │ Rules        │
                       └──────────────┘
```

### 2. Private Access with External VNet
```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Application   │───▶│   Your VNet      │───▶│  MySQL Server    │
│                 │    │   Your Subnet    │    │  (Private)       │
└─────────────────┘    └──────────────────┘    └──────────────────┘
```

### 3. Private Access with Module VNet
```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Application   │───▶│  Module VNet     │───▶│  MySQL Server    │
│                 │    │  Module Subnet   │    │  (Private)       │
└─────────────────┘    └──────────────────┘    └──────────────────┘
```

## Usage

### Basic Example (Public Access)

```hcl
module "mysql_database" {
  source = "./child_modules/MYSQL-Database"

  # Resource Group
  resource_group_name = "my-mysql-rg"
  location           = "East US"

  # MySQL Server Configuration
  mysql_server_name     = "my-mysql-server"
  mysql_admin_username  = "mysqladmin"
  mysql_admin_password  = "SecurePassword123!"
  mysql_server_sku      = "Standard_D2ds_v4"

  # Multiple Databases
  mysql_databases = {
    "app_db" = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
    "logging_db" = {
      charset   = "utf8"
      collation = "utf8_general_ci"
    }
  }

  # Firewall Rule
  firewall_rule_name              = "allow-office"
  firewall_rule_start_ip_address  = "203.0.113.0"
  firewall_rule_end_ip_address    = "203.0.113.255"

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Private Access with External Subnet

```hcl
module "mysql_database" {
  source = "./child_modules/MYSQL-Database"

  # Resource Group
  resource_group_name = "my-mysql-rg"
  location           = "East US"

  # MySQL Server Configuration
  mysql_server_name     = "my-mysql-server"
  mysql_admin_username  = "mysqladmin"
  mysql_admin_password  = "SecurePassword123!"
  mysql_server_sku      = "Standard_D4ds_v4"

  # VNet Integration with External Subnet
  enable_vnet_integration = true
  delegated_subnet_id     = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/mysql-subnet"
  private_dns_zone_id     = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/privateDnsZones/myapp.mysql.database.azure.com"

  # Multiple Databases
  mysql_databases = {
    "production_db" = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  }

  # High Availability
  mysql_server_high_availability_mode = "ZoneRedundant"

  tags = {
    Environment = "production"
    Tier       = "database"
  }
}
```

### Private Access with Module-Created VNet

```hcl
module "mysql_database" {
  source = "./child_modules/MYSQL-Database"

  # Resource Group
  resource_group_name = "my-mysql-rg"
  location           = "East US"

  # MySQL Server Configuration
  mysql_server_name     = "my-mysql-server"
  mysql_admin_username  = "mysqladmin"
  mysql_admin_password  = "SecurePassword123!"
  mysql_server_sku      = "Standard_D2ds_v4"

  # VNet Integration with Module VNet
  enable_vnet_integration        = true
  mysql_vnet_name               = "mysql-vnet"
  mysql_vnet_address_space      = ["10.0.0.0/16"]
  mysql_subnet_name             = "mysql-subnet"
  mysql_subnet_address_prefixes = ["10.0.1.0/24"]
  mysql_subnet_service_endpoints = ["Microsoft.Storage"]

  # Multiple Databases
  mysql_databases = {
    "app_db" = {}  # Uses defaults: utf8 and utf8_general_ci
    "cache_db" = {
      charset   = "latin1"
      collation = "latin1_swedish_ci"
    }
  }

  # Managed Identity
  mysql_server_identity_type = "SystemAssigned"

  tags = {
    Environment = "development"
  }
}
```

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| resource_group_name | Name of the Azure Resource Group | `string` |
| location | Azure region for deployment | `string` |
| mysql_server_name | Name of the MySQL Flexible Server | `string` |
| mysql_admin_username | Administrator username | `string` |
| mysql_admin_password | Administrator password | `string` |
| mysql_server_sku | MySQL server SKU | `string` |
| mysql_databases | Map of databases to create | `map(object)` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_vnet_integration | Enable VNet integration | `bool` | `false` |
| mysql_server_version | MySQL version | `string` | `"8.0"` |
| mysql_server_size_in_gb | Storage size in GB | `number` | `32` |
| mysql_server_backup_retention_days | Backup retention days | `number` | `7` |
| enable_geo_redundant_backup | Enable geo-redundant backups | `bool` | `false` |
| msql_serverzone | Availability zone | `number` | `1` |
| mysql_server_high_availability_mode | HA mode | `string` | `"ZoneRedundant"` |
| mysql_server_identity_type | Identity type | `string` | `"SystemAssigned"` |
| mysql_server_identity_ids | User assigned identity IDs | `list(string)` | `[]` |
| maintenance_window | Maintenance window configuration | `object` | `{}` |
| delegated_subnet_id | External subnet ID for VNet integration | `string` | `null` |
| private_dns_zone_id | Private DNS zone ID | `string` | `null` |
| mysql_vnet_name | VNet name (if module creates) | `string` | `null` |
| mysql_vnet_address_space | VNet address space | `list(string)` | `null` |
| mysql_subnet_name | Subnet name (if module creates) | `string` | `null` |
| mysql_subnet_address_prefixes | Subnet address prefixes | `list(string)` | `null` |
| mysql_subnet_service_endpoints | Subnet service endpoints | `list(string)` | `[]` |
| firewall_rule_name | Firewall rule name | `string` | `null` |
| firewall_rule_start_ip_address | Firewall start IP | `string` | `null` |
| firewall_rule_end_ip_address | Firewall end IP | `string` | `null` |
| create_mode | MySQL server create mode | `string` | `"Default"` |
| tags | Resource tags | `map(string)` | `{}` |

### Variable Validation Rules

- **mysql_server_high_availability_mode**: Must be "ZoneRedundant", "SameZone", or "Disabled"
- **mysql_server_identity_type**: Must be "SystemAssigned" or "UserAssigned"
- **mysql_server_identity_ids**: Required when identity_type is "UserAssigned"
- **mysql_databases**: At least one database must be specified
- **VNet Integration**: When enabled, either provide delegated_subnet_id OR VNet/subnet creation parameters

## Outputs

| Name | Description |
|------|-------------|
| resource_group_id | Resource group ID |
| mysql_server_id | MySQL server ID |
| mysql_server_fqdn | MySQL server FQDN |
| mysql_server_identity | Server identity information |
| mysql_server_storage_info | Storage configuration details |
| mysql_server_high_availability | HA configuration |
| mysql_databases | Database details with IDs |
| mysql_vnet_id | VNet ID (if created by module) |
| mysql_subnet_id | Subnet ID (if created by module) |
| delegated_subnet_id_used | Actual subnet ID used by server |
| firewall_rule_id | Firewall rule ID (if created) |
| mysql_connection_string | Connection string template |

## Database Configuration

The `mysql_databases` variable supports multiple databases with individual configuration:

```hcl
mysql_databases = {
  "database_name" = {
    charset   = "utf8mb4"           # Optional, defaults to "utf8"
    collation = "utf8mb4_unicode_ci" # Optional, defaults to "utf8_general_ci"
  }
}
```

**Supported Charset/Collation Examples:**
- `utf8` / `utf8_general_ci` (default)
- `utf8mb4` / `utf8mb4_unicode_ci` (recommended for full Unicode support)
- `latin1` / `latin1_swedish_ci`

## VNet Integration Options

### Option 1: Use Existing Subnet
```hcl
enable_vnet_integration = true
delegated_subnet_id     = "/subscriptions/.../subnets/mysql-subnet"
```

### Option 2: Create VNet and Subnet
```hcl
enable_vnet_integration        = true
mysql_vnet_name               = "mysql-vnet"
mysql_vnet_address_space      = ["10.0.0.0/16"]
mysql_subnet_name             = "mysql-subnet"
mysql_subnet_address_prefixes = ["10.0.1.0/24"]
```

## High Availability Options

| Mode | Description | Use Case |
|------|-------------|----------|
| `ZoneRedundant` | Standby in different zone | Production workloads |
| `SameZone` | Standby in same zone | Cost-optimized HA |
| `Disabled` | No standby server | Development/testing |

## Security Features

- **Network Security**: VNet integration with subnet delegation
- **Access Control**: Firewall rules for public access
- **Identity**: Managed identities for secure authentication
- **Encryption**: Encryption at rest and in transit
- **Backup**: Automated backups with geo-redundancy option

## Examples

See the `/examples` directory for:
- Basic public MySQL deployment
- Private MySQL with existing VNet
- Multi-database configuration
- High availability setup

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >= 3.0 |

## License

This module is released under the MIT License.

## Contributing

Please submit issues and enhancement requests via GitHub issues.
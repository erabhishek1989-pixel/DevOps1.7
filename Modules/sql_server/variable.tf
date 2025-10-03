variable "sql_server_name" {
  type = string
}

variable "sql_databases" {
  type = map(object({
    name           = string
    max_size_gb    = number
    sku_name       = string
    zone_redundant = bool
  }))
  description = "Map of SQL databases to create"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "azuread_administrator" {
  type = object({
    login_username              = string
    object_id                   = string
    azuread_authentication_only = optional(bool, false)
  })
  description = "Azure AD administrator configuration for SQL Server"
  default     = null
}

variable "sql_version" {
  type    = string
  default = "12.0"
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "enable_private_endpoint" {
  type    = bool
  default = true
}

variable "private_endpoint_name" {
  type = string
}

variable "private_service_connection_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_dns_zone_ids" {
  type    = list(string)
  default = []
}

# Failover Group Variables
variable "enable_failover_group" {
  type        = bool
  description = "Enable SQL failover group for geo-replication"
  default     = false
}

variable "secondary_location" {
  type        = string
  description = "Location for secondary SQL server"
  default     = null
}

variable "secondary_resource_group_name" {
  type        = string
  description = "Resource group for secondary SQL server"
  default     = null
}

variable "secondary_server_name" {
  type        = string
  description = "Name of the secondary SQL server"
  default     = null
}

variable "secondary_subnet_id" {
  type        = string
  description = "Subnet ID for secondary server private endpoint"
  default     = null
}

variable "secondary_private_endpoint_name" {
  type        = string
  description = "Name of the private endpoint for secondary server"
  default     = null
}

variable "secondary_private_service_connection_name" {
  type        = string
  description = "Name of the private service connection for secondary server"
  default     = null
}

variable "failover_group_name" {
  type        = string
  description = "Name of the failover group"
  default     = null
}

variable "failover_group_read_write_policy" {
  type = object({
    mode          = string
    grace_minutes = optional(number)
  })
  description = "Read-write endpoint failover policy"
  default = {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

variable "tags" {
  type    = map(any)
  default = {}
}
variable "sql_failover_config" {
  type = object({
    enabled                                   = bool
    secondary_location                        = string
    secondary_resource_group                  = string
    secondary_server_name                     = string
    secondary_subnet_name                     = string
    failover_group_name                       = string
    grace_minutes                             = number
    secondary_private_endpoint_name           = string
    secondary_private_service_connection_name = string
  })
  description = "Configuration for SQL Failover Group"
  default     = null
}
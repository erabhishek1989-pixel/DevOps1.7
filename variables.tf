variable "environment" {
  type        = string
  description = "The environment name (Development, Staging, Production)"
}

variable "environment_identifier" {
  type        = string
  description = "The environment identifier (d3, s3, y3)"
}

variable "tenant_id" {
  type        = string
  description = "The Azure AD tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID"
}

variable "infrastructure_client_id" {
  type        = string
  description = "The infrastructure client ID"
}

variable "infra_client_ent_app__object_id" {
  type        = string
  description = "The infrastructure client enterprise application object ID"
}

variable "resource_groups_map" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource groups to create"
}

variable "keyvault_map" {
  type = map(object({
    keyvault_name       = string
    resource_group_name = string
    location            = string
    private_endpoint = object({
      name                  = string
      subnet_name           = string
      virtual_network_name  = string
      private_dns_zone_name = string
      static_ip = object({
        configuration_name = string
        address            = string
      })
    })
  }))
  description = "Map of key vaults to create"
}

variable "storage_accounts" {
  type = map(object({
    name                          = optional(string)
    resource_group_name           = optional(string)
    location                      = string
    private_endpoint_enabled      = bool
    public_network_access_enabled = optional(bool)
    account_kind                  = optional(string)
    account_replication_type      = optional(string)
    account_tier                  = optional(string)
    is_hns_enabled                = optional(bool)
    sftp_enabled                  = optional(bool)
    sftp_local_users = map(object({
      name              = optional(string)
      keyvault          = optional(string)
      permission_create = optional(bool)
      permission_delete = optional(bool)
      permission_list   = optional(bool)
      permission_read   = optional(bool)
      permission_write  = optional(bool)
    }))
  }))
  description = "Map of storage accounts to create"
}

variable "EntraID_Groups" {
  type = map(object({
    group_name       = string
    security_enabled = bool
  }))
  description = "Map of Entra ID groups to create"
}

variable "virtual_networks" {
  type = map(object({
    name          = string
    location      = string
    address_space = list(string)
    peerings = map(object({
      name        = string
      remote_peer = bool
    }))
    subnets = map(object({
      name             = string
      address_prefixes = list(string)
      delegation       = optional(list(string))
    }))
    route_tables = map(object({
      name = string
      routes = map(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = string
      }))
    }))
  }))
  description = "Map of virtual networks to create"
}

variable "virtual_networks_dns_servers" {
  type        = list(string)
  description = "List of DNS servers for virtual networks"
}

variable "amexpagero_resources" {
  type = object({
    sql_server_name                     = string
    sql_database_name                   = string
    sql_admin_username                  = string
    app_service_plan_name               = string
    app_service_name                    = string
    sql_private_endpoint_name           = string
    sql_private_service_connection_name = string
  })
  description = "Configuration for AMEX Pagero resources"
  default     = null
}

variable "sql_server_config" {
  type = object({
    version                       = string
    minimum_tls_version           = string
    public_network_access_enabled = bool
  })
  description = "Configuration for SQL Server"
  default     = null
}

variable "sql_databases_config" {
  type = map(object({
    name           = string
    max_size_gb    = number
    sku_name       = string
    zone_redundant = bool
  }))
  description = "Configuration for SQL Databases"
  default     = {}
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
variable "app_service_config" {
  type = object({
    python_version = string
    sku_name       = string
    sku_tier       = string
  })
  description = "Configuration for App Service"
  default     = null
}
variable "service_bus_config" {
  type = object({
    sku                           = string
    public_network_access_enabled = bool
    minimum_tls_version           = string
    queues = map(object({
      name                                 = string
      enable_partitioning                  = optional(bool)
      max_size_in_megabytes                = optional(number)
      requires_duplicate_detection         = optional(bool)
      requires_session                     = optional(bool)
      dead_lettering_on_message_expiration = optional(bool)
      default_message_ttl                  = optional(string)
      lock_duration                        = optional(string)
      max_delivery_count                   = optional(number)
    }))
    topics = map(object({
      name                  = string
      enable_partitioning   = optional(bool)
      max_size_in_megabytes = optional(number)
      default_message_ttl   = optional(string)
    }))
    subscriptions = map(object({
      name                                 = string
      topic_name                           = string
      max_delivery_count                   = optional(number)
      lock_duration                        = optional(string)
      requires_session                     = optional(bool)
      dead_lettering_on_message_expiration = optional(bool)
    }))
  })
  description = "Configuration for Service Bus"
  default     = null
}
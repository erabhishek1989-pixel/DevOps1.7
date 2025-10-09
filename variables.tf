#---------ENVIRONMENT-----------#
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


#---------KEY VAULT-----------#
variable "keyvault_map" {
  type = map(object({
    keyvault_name       = string
    resource_group_name = string
    location            = string
    
      allowed_subnet_ids = optional(list(object({
      virtual_network_name = string
      subnet_name          = string
    })), [])
    
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
    
    # Changing this to explicit rathar than map-Abhishek
    virtual_network_name = string
    subnet_name          = string
    keyvault_name        = string
    
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

#---------ENTRA ID-----------#
variable "EntraID_Groups" {
  type = map(object({
    group_name       = string
    security_enabled = bool
    keyvault_assignments = optional(map(object({
      keyvault_id = string
      role_name   = string
    })), {})
    storage_assignments = optional(map(object({
      storage_id = string
      role_name  = string
    })), {})
  }))
  description = "Map of Entra ID groups to create with its role assignments"
}

#---------NETWORK-----------#
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

#---------APP SERVICE-----------#

variable "app_services" {
  type = map(object({
    app_service_plan_name = string
    app_service_name      = string
    resource_group_name   = string
    location              = string
    sku_name              = string
    python_version        = string
    always_on             = bool
    
    enable_vnet_integration = bool
    virtual_network_name    = optional(string)
    subnet_name             = optional(string)
    
    app_settings      = map(string)
    keyvault_name     = string
    sql_server_key    = optional(string)
    storage_account_key = optional(string)
    service_bus_key   = optional(string)
  }))
  description = "Map of App Service configurations"
  default     = {}
}

#---------SERVICE BUS-----------#
variable "service_buses" {
  type = map(object({
    service_bus_name              = string
    resource_group_name           = string
    location                      = string
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
    
    # Networking
    enable_private_endpoint         = bool
    private_endpoint_name           = string
    private_service_connection_name = string
    virtual_network_name            = string
    subnet_name                     = string
    private_dns_zone_ids            = list(string)
    
    # Key Vault for storing connection string
    keyvault_name = string
  }))
  description = "Map of Service Bus configurations"
  default     = {}
}


#---------SQL-----------#
variable "sql_servers" {
  type = map(object({
    sql_server_name                     = string
    sql_databases                       = map(object({
      name           = string
      max_size_gb    = number
      sku_name       = string
      zone_redundant = bool
    }))
    resource_group_name                 = string
    location                            = string
    sql_admin_username                  = string
    enable_azure_ad_admin               = bool
    azure_ad_admin_group_name           = optional(string)
    sql_version                         = optional(string, "12.0")
    minimum_tls_version                 = optional(string, "1.2")
    public_network_access_enabled       = optional(bool, false)
    enable_private_endpoint             = optional(bool, true)
    private_endpoint_name               = string
    private_service_connection_name     = string
    subnet_name                         = string
    vnet_name                           = string
    private_dns_zone_ids                = list(string)
    
    failover_config = optional(object({
      enabled                                   = bool
      secondary_location                        = string
      secondary_resource_group                  = string
      secondary_server_name                     = string
      secondary_subnet_name                     = string
      secondary_vnet_name                       = string
      failover_group_name                       = string
      grace_minutes                             = number
      secondary_private_endpoint_name           = string
      secondary_private_service_connection_name = string
    }))
    
    keyvault_name                       = string
    store_connection_strings            = optional(bool, true)
  }))
  description = "Map of SQL Server configurations"
  default     = {}
}

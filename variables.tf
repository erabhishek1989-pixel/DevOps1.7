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

variable "core_networking_tenant_id" {
  type        = string
  description = "The core networking tenant ID"
}

variable "core_networking_subscription_id" {
  type        = string
  description = "The core networking subscription ID"
}

variable "infrastructure_client_id" {
  type        = string
  description = "The infrastructure client ID"
}

variable "infra_client_ent_app__object_id" {
  type        = string
  description = "The infrastructure client enterprise application object ID"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

#---------RESOURCE GROUPS-----------#
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
      virtual_network_key = string
      subnet_name         = string
    })), [])
    
    private_endpoint = object({
      name                            = string
      subnet_name                     = string
      virtual_network_key             = string
      private_service_connection_name = string
      static_ip = optional(object({
        configuration_name = string
        address            = string
      }))
    })
  }))
  description = "Map of key vaults to create"
}

#---------STORAGE ACCOUNTS-----------#
variable "storage_accounts" {
  type = map(object({
    name                          = string
    resource_group_key            = string
    location                      = string
    private_endpoint_enabled      = bool
    public_network_access_enabled = optional(bool, false)
    account_kind                  = string
    account_replication_type      = string
    account_tier                  = string
    is_hns_enabled                = bool
    sftp_enabled                  = bool
    virtual_network_key           = string
    subnet_name                   = string
    keyvault_key                  = string
    
    sftp_local_users = optional(map(object({
      name              = string
      keyvault          = optional(string)
      permission_create = optional(bool, false)
      permission_delete = optional(bool, false)
      permission_list   = optional(bool, false)
      permission_read   = optional(bool, false)
      permission_write  = optional(bool, false)
    })), {})
  }))
  description = "Map of storage accounts to create"
}

#---------ENTRA ID-----------#
variable "EntraID_Groups" {
  type = map(object({
    group_name       = string
    security_enabled = bool
    role_assignments = optional(map(object({
      scope     = string
      role_name = string
    })), {})
  }))
  description = "Map of Entra ID groups to create with their role assignments"
}

#---------NETWORK-----------#
variable "virtual_networks" {
  type = map(object({
    name               = string
    location           = string
    resource_group_key = string
    address_space      = list(string)
    peerings = map(object({
      name        = string
      remote_peer = bool
    }))
    subnets = map(object({
      name             = string
      address_prefixes = list(string)
      delegation       = optional(list(string), [])
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
    app_service_plan_name   = string
    app_service_name        = string
    resource_group_key      = string
    location                = string
    sku_name                = string
    python_version          = string
    always_on               = bool
    enable_vnet_integration = bool
    virtual_network_key     = optional(string)
    subnet_name             = optional(string)
    
 
    keyvault_secrets      = optional(map(string), {})  # Map of setting_name, changed as per the feedback
    static_app_settings   = optional(map(string), {})  # Map of static settings
    
    keyvault_key = string
  }))
  description = "Map of App Service configurations"
  default     = {}
}

#---------SERVICE BUS-----------#
variable "service_buses" {
  type = map(object({
    service_bus_name              = string
    resource_group_key            = string
    location                      = string
    sku                           = string
    capacity                      = optional(number, 0)
    public_network_access_enabled = optional(bool, true)
    minimum_tls_version           = optional(string, "1.2")
    
    queues = optional(map(object({
      name                                 = string
      max_size_in_megabytes                = optional(number, 1024)
      requires_duplicate_detection         = optional(bool, false)
      requires_session                     = optional(bool, false)
      dead_lettering_on_message_expiration = optional(bool, false)
      default_message_ttl                  = optional(string, "P14D")
      lock_duration                        = optional(string, "PT1M")
      max_delivery_count                   = optional(number, 10)
    })), {})
    
    topics = optional(map(object({
      name                  = string
      max_size_in_megabytes = optional(number, 1024)
      default_message_ttl   = optional(string, "P14D")
    })), {})
    
    subscriptions = optional(map(object({
      name                                 = string
      topic_name                           = string
      max_delivery_count                   = optional(number, 10)
      lock_duration                        = optional(string, "PT1M")
      requires_session                     = optional(bool, false)
      dead_lettering_on_message_expiration = optional(bool, false)
    })), {})
    
    # Private Endpoint - All Optional
    enable_private_endpoint         = optional(bool, false)
    private_endpoint_name           = optional(string, "")
    private_service_connection_name = optional(string, "")
    virtual_network_key             = optional(string, "")
    subnet_name                     = optional(string, "")
    private_dns_zone_ids            = optional(list(string), [])
    
    keyvault_key = optional(string, null)
  }))
  description = "Map of Service Bus configurations"
  default     = {}
}

#---------SQL-----------#
variable "sql_servers" {
  type = map(object({
    sql_server_name        = string
    sql_databases = map(object({
      name           = string
      max_size_gb    = number
      sku_name       = string
      zone_redundant = bool
    }))
    resource_group_key                = string
    location                          = string
    sql_admin_username                = string
    enable_azure_ad_admin             = bool
    azure_ad_admin_group_name         = optional(string)
    azuread_authentication_only       = optional(bool, false)
    sql_version                       = optional(string, "12.0")
    minimum_tls_version               = optional(string, "1.2")
    public_network_access_enabled     = optional(bool, false)
    enable_private_endpoint           = optional(bool, true)
    private_endpoint_name             = string
    private_service_connection_name   = string
    subnet_name                       = string
    virtual_network_key               = string
    private_dns_zone_ids              = list(string)
    
    failover_config = optional(object({
      enabled                         = bool
      secondary_location              = string
      secondary_resource_group_key    = string
      secondary_server_name           = string
      secondary_subnet_name           = string
      secondary_virtual_network_key   = string
      failover_group_name             = string
      failover_mode                   = optional(string, "Automatic")
      grace_minutes                   = number
      secondary_private_endpoint_name           = string
      secondary_private_service_connection_name = string
    }))
    
    keyvault_key             = string
    store_connection_strings = optional(bool, true)
  }))
  description = "Map of SQL Server configurations"
  default     = {}
}
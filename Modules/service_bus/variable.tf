variable "service_bus_name" {
  type        = string
  description = "Name of the Service Bus namespace"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "sku" {
  type        = string
  description = "SKU of the Service Bus namespace (Basic, Standard, Premium)"
  default     = "Standard"
}

variable "capacity" {
  type        = number
  description = "Capacity for Premium SKU (1, 2, 4, 8, 16)"
  default     = 0
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled"
  default     = true  # Changed to true by default
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.2"
}

variable "queues" {
  type = map(object({
    name                                 = string
    max_size_in_megabytes               = optional(number)
    requires_duplicate_detection         = optional(bool)
    requires_session                     = optional(bool)
    dead_lettering_on_message_expiration = optional(bool)
    default_message_ttl                  = optional(string)
    lock_duration                        = optional(string)
    max_delivery_count                   = optional(number)
  }))
  description = "Map of Service Bus queues"
  default     = {}
}

variable "topics" {
  type = map(object({
    name                  = string
    max_size_in_megabytes = optional(number)
    default_message_ttl   = optional(string)
  }))
  description = "Map of Service Bus topics"
  default     = {}
}

variable "subscriptions" {
  type = map(object({
    name                                 = string
    topic_name                           = string
    max_delivery_count                   = optional(number)
    lock_duration                        = optional(string)
    requires_session                     = optional(bool)
    dead_lettering_on_message_expiration = optional(bool)
  }))
  description = "Map of Service Bus subscriptions"
  default     = {}
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable private endpoint"
  default     = false  # Changed to false by default
}

variable "private_endpoint_name" {
  type        = string
  description = "Name of the private endpoint"
  default     = ""
}

variable "private_service_connection_name" {
  type        = string
  description = "Name of the private service connection"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint"
  default     = ""
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Private DNS zone IDs"
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources"
  default     = {}
}

variable "keyvault_id" {
  type        = string
  description = "Key Vault ID for storing connection string"
  default     = null
}
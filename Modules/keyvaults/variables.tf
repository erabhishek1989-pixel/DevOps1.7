variable "rg-name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "environment_identifier" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type = string
}

variable "private_endpoint" {
  type = object({
    name                            = string
    subnet_id                       = string
    private_dns_zone_id             = string
    private_service_connection_name = string
    static_ip = object({
      configuration_name = string
      address            = string
    })
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
}

variable "infra_client_ent_app__object_id" {
  type = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses for Key Vault access"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs for Key Vault access"
  type        = list(string)
  default     = []
}

variable "network_acls_enabled" {
  description = "Whether to enable network ACLs"
  type        = bool
  default     = true
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
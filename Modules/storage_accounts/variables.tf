variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_replication_type" {
  type = string
}

variable "account_tier" {
  type = string
}

variable "private_endpoint_enabled" {
  type = bool
}

variable "account_kind" {
  type = string
}

variable "is_hns_enabled" {
  type = bool
}

variable "sftp_enabled" {
  type = bool
}

variable "sftp_local_users" {
  type = map(object({
    name               = optional(string)
    keyvault           = optional(string)
    permission_create  = optional(bool)
    permission_delete  = optional(bool)
    permission_list    = optional(bool)
    permission_read    = optional(bool)
    permission_write   = optional(bool)
  }))
}

variable "subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "keyvault_id" {
  type = string
}

variable "environment_identifier" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}
variable "tags" {
  type    = map(any)
  default = {}
}
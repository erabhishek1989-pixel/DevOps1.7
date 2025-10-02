variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
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

variable "database_max_size_gb" {
  type    = number
  default = 32
}

variable "database_sku_name" {
  type    = string
  default = "GP_Gen5_2"
}

variable "database_zone_redundant" {
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

variable "tags" {
  type    = map(any)
  default = {}
}
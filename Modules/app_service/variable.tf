
variable "app_service_plan_name" {
  type = string
}

variable "app_service_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "python_version" {
  type    = string
  default = "3.10"
}

variable "always_on" {
  type    = bool
  default = false
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "enable_vnet_integration" {
  type    = bool
  default = false
}

variable "vnet_integration_subnet_id" {
  type    = string
  default = null
}
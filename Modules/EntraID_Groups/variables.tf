variable "display_name" {
  type = string
}

variable "security_enabled" {
  type = bool
}

variable "subscription_id" {
  type = string
}
variable "keyvault_assignments" {
  type = map(object({
    keyvault_id = string
    role_name   = string
  }))
  description = "Map of Key Vault role assignments for this group"
  default     = {}
}

variable "storage_assignments" {
  type = map(object({
    storage_id = string
    role_name  = string
  }))
  description = "Map of Storage role assignments for this group"
  default     = {}
}
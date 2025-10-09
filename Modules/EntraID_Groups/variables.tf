variable "display_name" {
  type        = string
  description = "Display name of the Entra ID group"
}

variable "security_enabled" {
  type        = bool
  description = "Whether the group is security enabled"
}

variable "role_assignments" {
  type = map(object({
    scope     = string
    role_name = string
  }))
  description = "Map of role assignments for this group"
  default     = {}
}
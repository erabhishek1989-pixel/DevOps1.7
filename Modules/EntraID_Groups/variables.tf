variable "display_name" {
  type        = string
  description = "Display name of the Entra ID group"
}

variable "security_enabled" {
  type        = bool
  description = "Whether the group is security enabled"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID for role assignments (in format: /subscriptions/xxx)"
}
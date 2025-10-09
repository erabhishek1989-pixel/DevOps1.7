output "object_id" {
  value       = azuread_group.EntraID_Group.object_id
  description = "The object ID of the Entra ID group"
}

output "group_name" {
  value       = azuread_group.EntraID_Group.display_name
  description = "The display name of the Entra ID group"
}

output "group_id" {
  value       = azuread_group.EntraID_Group.id
  description = "The ID of the Entra ID group"
}
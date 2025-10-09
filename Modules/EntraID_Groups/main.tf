resource "azuread_group" "EntraID_Group" {
  display_name            = var.display_name
  security_enabled        = var.security_enabled
  prevent_duplicate_names = true
}

# Generic role assignments 
resource "azurerm_role_assignment" "role_assignments" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.EntraID_Group.object_id
}
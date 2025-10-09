resource "azuread_group" "EntraID_Group" {
  display_name            = var.display_name
  security_enabled        = var.security_enabled
  prevent_duplicate_names = true
}

resource "azurerm_role_assignment" "sub-rbac-tax" {
  scope                = var.subscription_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.EntraID_Group.object_id
}

resource "azurerm_role_assignment" "sql-firewall-rbac-tax" {
  scope                = var.subscription_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_group.EntraID_Group.object_id
}
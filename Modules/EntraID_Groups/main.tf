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
# Role assignments for Key Vault
resource "azurerm_role_assignment" "group_keyvault_access" {
  for_each = var.keyvault_assignments

  scope                = each.value.keyvault_id
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.EntraID_Group.object_id
}

# Role assignments for Storage
resource "azurerm_role_assignment" "group_storage_access" {
  for_each = var.storage_assignments

  scope                = each.value.storage_id
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.EntraID_Group.object_id
}
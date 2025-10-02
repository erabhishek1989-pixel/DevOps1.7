output "keyvault_id" {
  value = azurerm_key_vault.keyvault.id
}

output "keyvault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}

output "private_endpoint_id" {
  value = var.private_endpoint != null ? azurerm_private_endpoint.private_endpoint[0].id : null
}
resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.environment_identifier}-${var.key_vault_name}"
  location                    = var.location
  resource_group_name         = "${var.environment_identifier}-${var.rg-name}"
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  sku_name                    = "standard"

  # NETWORK ACLs FOR SECURITY
  #dynamic "network_acls" {
  #  for_each = var.network_acls_enabled ? [1] : []
  #  
  #  content {
  #    default_action             = "Deny"
  #    bypass                     = "AzureServices"
  #    ip_rules                   = var.allowed_ips
  #    virtual_network_subnet_ids = var.allowed_subnet_ids
  #  }
  #}

  tags = var.tags
}

resource "azurerm_private_endpoint" "private_endpoint" {
  count = var.private_endpoint != null ? 1 : 0

  name                = var.private_endpoint.name
  location            = var.location
  resource_group_name = "${var.environment_identifier}-${var.rg-name}"
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = var.private_endpoint.private_service_connection_name
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint.static_ip != null ? [1] : []

    content {
      name               = var.private_endpoint.static_ip.configuration_name
      private_ip_address = var.private_endpoint.static_ip.address
      subresource_name   = "vault"
      member_name        = "default"
    }
  }

  private_dns_zone_group {
    name                 = "key-vault-dns-zone-group"
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "role_assignment_spn_key_vault_administrator" {
  scope                = azurerm_key_vault.keyvault.id
  principal_id         = var.infra_client_ent_app__object_id
  role_definition_name = "Key Vault Administrator"
}

resource "azurerm_role_assignment" "role_assignment_spn_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.keyvault.id
  principal_id         = var.infra_client_ent_app__object_id
  role_definition_name = "Key Vault Secrets Officer"
}
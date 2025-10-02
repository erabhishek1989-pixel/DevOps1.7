resource "azurerm_storage_account" "storage_account" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  is_hns_enabled           = var.is_hns_enabled
  sftp_enabled             = var.sftp_enabled
  
  # SECURITY 
  min_tls_version          = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags  
}

resource "azurerm_private_endpoint" "private_endpoint" {
  count = var.private_endpoint_enabled ? 1 : 0

  name                = "priv-nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-account-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  depends_on = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_container" "sftp_storage_container" {
  for_each = var.sftp_enabled == true ? { for index, sftp_storage_container in var.sftp_local_users : sftp_storage_container.name => sftp_storage_container } : {}

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage_account.name
  depends_on           = [azurerm_storage_account.storage_account]
}

resource "azurerm_storage_account_local_user" "storage_account_local_user" {
  for_each = var.sftp_enabled == true ? { for index, sftp_local_user in var.sftp_local_users : sftp_local_user.name => sftp_local_user } : {}

  name                 = "${var.environment_identifier}${each.value.name}"
  storage_account_id   = azurerm_storage_account.storage_account.id
  ssh_key_enabled      = false
  home_directory       = each.value.name
  ssh_password_enabled = true

  permission_scope {
    service       = "blob"
    resource_name = each.value.name
    permissions {
      create = each.value.permission_create
      delete = each.value.permission_delete
      list   = each.value.permission_list
      read   = each.value.permission_read
      write  = each.value.permission_write
    }
  }

  depends_on = [azurerm_storage_account.storage_account, azurerm_storage_container.sftp_storage_container]
}

resource "azurerm_key_vault_secret" "keyvault_secret_sftp_user_password" {
  for_each = var.sftp_enabled == true ? { for index, keyvault_secret_sftp_user_password in var.sftp_local_users : keyvault_secret_sftp_user_password.name => keyvault_secret_sftp_user_password } : {}

  name         = "${each.value.name}-ssh-password"
  value        = azurerm_storage_account_local_user.storage_account_local_user["${each.value.name}"].password
  key_vault_id = var.keyvault_id
}
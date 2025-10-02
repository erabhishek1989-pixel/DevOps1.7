# Primary SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.sql_version
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled

    dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [1] : []
    content {
      login_username              = var.azuread_administrator.login_username
      object_id                   = var.azuread_administrator.object_id
      azuread_authentication_only = var.azuread_administrator.azuread_authentication_only
    }
  }

  tags = var.tags
}

# Multiple Databases on Primary Server
resource "azurerm_mssql_database" "sql_databases" {
  for_each = var.sql_databases

  name           = each.value.name
  server_id      = azurerm_mssql_server.sql_server.id
  max_size_gb    = each.value.max_size_gb
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant

  tags = var.tags
}

# Private Endpoint for Primary Server
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-private-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Secondary SQL Server (for Failover Group)
resource "azurerm_mssql_server" "sql_server_secondary" {
  count = var.enable_failover_group ? 1 : 0

  name                          = var.secondary_server_name
  resource_group_name           = var.secondary_resource_group_name
  location                      = var.secondary_location
  version                       = var.sql_version
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  
  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [1] : []
    content {
      login_username              = var.azuread_administrator.login_username
      object_id                   = var.azuread_administrator.object_id
      azuread_authentication_only = var.azuread_administrator.azuread_authentication_only
    }
  }
  tags = var.tags
}

# Private Endpoint for Secondary Server
resource "azurerm_private_endpoint" "sql_private_endpoint_secondary" {
  count = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0

  name                = var.secondary_private_endpoint_name
  location            = var.secondary_location
  resource_group_name = var.secondary_resource_group_name
  subnet_id           = var.secondary_subnet_id

  private_service_connection {
    name                           = var.secondary_private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.sql_server_secondary[0].id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-private-dns-zone-group-secondary"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Failover Group
resource "azurerm_mssql_failover_group" "failover_group" {
  count = var.enable_failover_group ? 1 : 0

  name      = var.failover_group_name
  server_id = azurerm_mssql_server.sql_server.id

  databases = [for db in azurerm_mssql_database.sql_databases : db.id]

  partner_server {
    id = azurerm_mssql_server.sql_server_secondary[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = var.failover_group_read_write_policy.mode
    grace_minutes = var.failover_group_read_write_policy.mode == "Automatic" ? var.failover_group_read_write_policy.grace_minutes : null
  }

  tags = var.tags

  depends_on = [
    azurerm_mssql_database.sql_databases,
    azurerm_mssql_server.sql_server_secondary
  ]
}
output "sql_server_id" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_ids" {
  value = { for k, v in azurerm_mssql_database.sql_databases : k => v.id }
  description = "Map of database IDs"
}

output "sql_database_names" {
  value = { for k, v in azurerm_mssql_database.sql_databases : k => v.name }
  description = "Map of database names"
}

output "sql_connection_strings" {
  value = {
    for k, v in azurerm_mssql_database.sql_databases :
    k => "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${v.name};User ID=${var.sql_admin_username};Password=${random_password.sql_admin_password.result};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  }
  sensitive   = true
  description = "Map of SQL connection strings"
}

# Secondary Server Outputs
output "sql_server_secondary_id" {
  value       = var.enable_failover_group ? azurerm_mssql_server.sql_server_secondary[0].id : null
  description = "Secondary SQL Server ID"
}

output "sql_server_secondary_fqdn" {
  value       = var.enable_failover_group ? azurerm_mssql_server.sql_server_secondary[0].fully_qualified_domain_name : null
  description = "Secondary SQL Server FQDN"
}

# Failover Group Outputs
output "failover_group_id" {
  value       = var.enable_failover_group ? azurerm_mssql_failover_group.failover_group[0].id : null
  description = "Failover Group ID"
}

output "failover_group_listener_endpoint" {
  value       = var.enable_failover_group ? "${var.failover_group_name}.database.windows.net" : null
  description = "Failover Group listener endpoint"
}

output "failover_group_readonly_endpoint" {
  value       = var.enable_failover_group ? "${var.failover_group_name}.secondary.database.windows.net" : null
  description = "Failover Group read-only endpoint"
}

# Password output (sensitive)
output "sql_admin_password" {
  value     = random_password.sql_admin_password.result
  sensitive = true
  description = "SQL Server admin password"
}
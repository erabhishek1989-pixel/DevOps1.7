output "sql_server_id" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_id" {
  value = azurerm_mssql_database.sql_database.id
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_database.name
}

output "sql_connection_string" {
  value     = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sql_database.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive = true
}
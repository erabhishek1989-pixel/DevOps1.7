output "app_service_plan_id" {
  value = azurerm_service_plan.app_service_plan.id
}

output "app_service_id" {
  value = azurerm_linux_web_app.app_service.id
}

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.app_service.default_hostname
}

output "app_service_name" {
  value = azurerm_linux_web_app.app_service.name
}

output "app_service_identity_principal_id" {
  value = azurerm_linux_web_app.app_service.identity[0].principal_id
}
output "service_bus_id" {
  value       = azurerm_servicebus_namespace.service_bus.id
  description = "The ID of the Service Bus namespace"
}

output "service_bus_name" {
  value       = azurerm_servicebus_namespace.service_bus.name
  description = "The name of the Service Bus namespace"
}

output "service_bus_endpoint" {
  value       = azurerm_servicebus_namespace.service_bus.endpoint
  description = "The endpoint of the Service Bus namespace"
}

output "primary_connection_string" {
  value       = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
  sensitive   = true
  description = "Primary connection string"
}

output "secondary_connection_string" {
  value       = azurerm_servicebus_namespace.service_bus.default_secondary_connection_string
  sensitive   = true
  description = "Secondary connection string"
}

output "queue_ids" {
  value       = { for k, v in azurerm_servicebus_queue.queues : k => v.id }
  description = "Map of queue IDs"
}

output "topic_ids" {
  value       = { for k, v in azurerm_servicebus_topic.topics : k => v.id }
  description = "Map of topic IDs"
}
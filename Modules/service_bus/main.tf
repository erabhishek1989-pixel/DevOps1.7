resource "azurerm_servicebus_namespace" "service_bus" {
  name                = var.service_bus_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version
  
  tags = var.tags
}

resource "azurerm_servicebus_queue" "queues" {
  for_each = var.queues

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.service_bus.id

  max_size_in_megabytes            = lookup(each.value, "max_size_in_megabytes", 1024)
  requires_duplicate_detection     = lookup(each.value, "requires_duplicate_detection", false)
  requires_session                 = lookup(each.value, "requires_session", false)
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", false)
  
  default_message_ttl = lookup(each.value, "default_message_ttl", "P14D")
  lock_duration       = lookup(each.value, "lock_duration", "PT1M")
  max_delivery_count  = lookup(each.value, "max_delivery_count", 10)

  depends_on = [azurerm_servicebus_namespace.service_bus]
}

resource "azurerm_servicebus_topic" "topics" {
  for_each = var.topics

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.service_bus.id

  max_size_in_megabytes = lookup(each.value, "max_size_in_megabytes", 1024)
  
  default_message_ttl = lookup(each.value, "default_message_ttl", "P14D")

  depends_on = [azurerm_servicebus_namespace.service_bus]
}

resource "azurerm_servicebus_subscription" "subscriptions" {
  for_each = var.subscriptions

  name               = each.value.name
  topic_id           = azurerm_servicebus_topic.topics[each.value.topic_name].id
  max_delivery_count = lookup(each.value, "max_delivery_count", 10)
  
  lock_duration                        = lookup(each.value, "lock_duration", "PT1M")
  requires_session                     = lookup(each.value, "requires_session", false)
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", false)

  depends_on = [azurerm_servicebus_topic.topics]
}

resource "azurerm_private_endpoint" "service_bus_private_endpoint" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    private_connection_resource_id = azurerm_servicebus_namespace.service_bus.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = "servicebus-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}
# Store Service Bus connection string in Key Vault
resource "azurerm_key_vault_secret" "service_bus_connection_string" {
  count = var.keyvault_id != null ? 1 : 0

  name         = "${var.service_bus_name}-connection-string"
  value        = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
  key_vault_id = var.keyvault_id
  
  depends_on = [azurerm_servicebus_namespace.service_bus]
}
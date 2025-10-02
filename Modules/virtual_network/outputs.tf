output "subnet_id" {
  value = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}

output "subnets" {
  value = {
    for i, subnet in azurerm_subnet.subnet : subnet.name => subnet
  }
}

output "vnet_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "name" {
  value = azurerm_virtual_network.virtual_network.name
}
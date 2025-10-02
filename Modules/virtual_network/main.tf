terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 4.0"
      configuration_aliases = [azurerm.y3-core-networking]
    }
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = var.resource_group_name
  dns_servers         = var.virtual_networks_dns_servers
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation != null ? each.value.delegation : []
    content {
      name = "delegation-${delegation.value}"
      service_delegation {
        name    = delegation.value
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
      }
    }
  }

  depends_on = [azurerm_virtual_network.virtual_network]
}

resource "azurerm_route_table" "route_table" {
  for_each            = var.route_tables
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_type == "VirtualAppliance" ? route.value.next_hop_in_ip_address : null
    }
  }
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  for_each = var.subnets

  # Dynamic route table reference
  route_table_id = azurerm_route_table.route_table[keys(var.route_tables)[0]].id
  subnet_id      = azurerm_subnet.subnet[each.key].id

  depends_on = [azurerm_subnet.subnet, azurerm_route_table.route_table]
}

resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each = {
    for i, peering in var.peerings : peering.name => peering
    if peering.remote_peer != true
  }

  name                      = each.value.name
  resource_group_name       = each.value.remote_peer != true ? var.resource_group_name : (var.location == "UK South" ? var.y3-rg-core-networking-uksouth-0001_name : var.y3-rg-core-networking-ukwest-0001_name)
  virtual_network_name      = each.value.remote_peer != true ? azurerm_virtual_network.virtual_network.name : (var.location == "UK South" ? var.y3-vnet-core-uksouth-0001_name : var.y3-vnet-core-ukwest-0001_name)
  remote_virtual_network_id = each.value.remote_peer != true ? (var.location == "UK South" ? var.y3-vnet-core-uksouth-0001_id : var.y3-vnet-core-ukwest-0001_id) : azurerm_virtual_network.virtual_network.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
  depends_on                = [azurerm_virtual_network.virtual_network]
}

resource "azurerm_virtual_network_peering" "vnet_peering_remote" {
  for_each = {
    for i, peering in var.peerings : peering.name => peering
    if peering.remote_peer == true
  }

  name                      = each.value.name
  resource_group_name       = each.value.remote_peer != true ? var.resource_group_name : (var.location == "UK South" ? var.y3-rg-core-networking-uksouth-0001_name : var.y3-rg-core-networking-ukwest-0001_name)
  virtual_network_name      = each.value.remote_peer != true ? azurerm_virtual_network.virtual_network.name : (var.location == "UK South" ? var.y3-vnet-core-uksouth-0001_name : var.y3-vnet-core-ukwest-0001_name)
  remote_virtual_network_id = each.value.remote_peer != true ? (var.location == "UK South" ? var.y3-vnet-core-uksouth-0001_id : var.y3-vnet-core-ukwest-0001_id) : azurerm_virtual_network.virtual_network.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  provider                  = azurerm.y3-core-networking

  depends_on = [azurerm_virtual_network.virtual_network]
}
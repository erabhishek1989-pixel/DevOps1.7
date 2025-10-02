variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "virtual_networks_dns_servers" {
  type = list(string)
}

variable "peerings" {
  type = map(object({
    name        = string
    remote_peer = bool
  }))
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    delegation       = optional(list(string))
  }))
}

variable "route_tables" {
  type = map(object({
    name = string
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = string
    }))
  }))
}

variable "y3-rg-core-networking-uksouth-0001_name" {
  type = string
}

variable "y3-rg-core-networking-ukwest-0001_name" {
  type = string
}

variable "y3-vnet-core-uksouth-0001_id" {
  type = string
}

variable "y3-vnet-core-uksouth-0001_name" {
  type = string
}

variable "y3-vnet-core-ukwest-0001_id" {
  type = string
}

variable "y3-vnet-core-ukwest-0001_name" {
  type = string
}
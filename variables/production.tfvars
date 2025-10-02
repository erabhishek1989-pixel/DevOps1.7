environment            = "Production"
environment_identifier = "y3"
subscription_id        = "a8c01ee3-0fcd-4f71-9b3a-5771c78d239a"

### NETWORKING ###

virtual_networks_dns_servers = ["10.0.0.116", "172.21.112.10"]

virtual_networks = {
  "vnet-tax-uksouth-0001" = {
    name          = "y3-vnet-tax-uksouth-0001"
    location      = "UK South"
    address_space = ["10.0.66.0/24"]
    peerings = {
      "tax_uksouth_to_core_uksouth" = {
        name        = "peer_prod_vnet_tax_uksouth_to_y3_core_networking_uksouth"
        remote_peer = false
      },
      "core_uksouth_to_tax_uksouth" = {
        name        = "peer_y3_core_networking_uksouth_to_prod_vnet_tax_uksouth"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-uksouth-storage" = {
        name             = "y3-snet-tax-uksouth-storage"
        address_prefixes = ["10.0.66.0/28"]
      },
      "snet-tax-uksouth-keyvault" = {
        name             = "y3-snet-tax-uksouth-keyvault"
        address_prefixes = ["10.0.66.16/28"]
      }

    }
    route_tables = {
      "route-tax-uksouth" = {
        name = "y3-route-tax-uksouth-0001"
        routes = {
          "default" = {
            name                   = "default"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.4"
          }
        }
      }
    }
  },
  "vnet-tax-ukwest-0001" = {
    name          = "y3-vnet-tax-ukwest-0001"
    location      = "UK West"
    address_space = ["10.2.66.0/24"]
    peerings = {
      "tax_ukwest_to_core_ukwest" = {
        name        = "peer_prod_vnet_tax_ukwest_to_y3_core_networking_ukwest"
        remote_peer = false
      },
      "core_ukwest_to_tax_ukwest" = {
        name        = "peer_y3_core_networking_ukwest_to_prod_vnet_tax_ukwest"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-ukwest-storage" = {
        name             = "y3-snet-tax-ukwest-storage"
        address_prefixes = ["10.2.66.0/28"]
      },
      "snet-tax-ukwest-keyvault" = {
        name             = "y3-snet-tax-ukwest-keyvault"
        address_prefixes = ["10.2.66.16/28"]
      }
    }
    route_tables = {
      "route-tax-uksouth" = {
        name = "y3-route-tax-ukwest-0001"
        routes = {
          "default" = {
            name                   = "default"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }
}
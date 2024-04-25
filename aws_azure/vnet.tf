resource "azurerm_resource_group" "ea2_rg_az" {
    name = "ea2_rg"
    location = "East US"
}

resource "azurerm_virtual_network" "ea2_vnet" {
  name                = "ea2_virtualnetwork"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.ea2_rg_az.location
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
}

resource "azurerm_subnet" "ea2_pvsubnet" {
  name                 = "ea2_pvsubnet"
  resource_group_name  = azurerm_resource_group.ea2_rg_az.name
  virtual_network_name = azurerm_virtual_network.ea2_vnet.name
  address_prefixes     = ["10.10.2.0/24"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  virtual_network_name = azurerm_virtual_network.ea2_vnet.name
  address_prefixes       = ["10.10.3.0/24"]
}

/*
resource "azurerm_public_ip" "natpip_az" {
  name                = "ea2_nat-PIP"
  location            = azurerm_resource_group.ea2_rg_az.location
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "ea2_nat_az" {
  name                = "ea2-natgateway"
  location            = azurerm_resource_group.ea2_rg_az.location
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
}

resource "azurerm_subnet_nat_gateway_association" "ea2_az_natasso" {
  subnet_id      = azurerm_subnet.ea2_pvsubnet.id
  nat_gateway_id = azurerm_nat_gateway.ea2_nat_az.id
}

resource "azurerm_nat_gateway_public_ip_association" "ea2_az_natipasso" {
  nat_gateway_id       = azurerm_nat_gateway.ea2_nat_az.id
  public_ip_address_id = azurerm_public_ip.natpip_az.id
}
*/

resource "azurerm_route_table" "ea2_pvsn_rt_az" {
  name = "ea2_routetable_pvsubnet"
  location            = azurerm_resource_group.ea2_rg_az.location
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  disable_bgp_route_propagation = false

  route {
    name           = "localroute"
    address_prefix = "10.10.0.0/16"
    next_hop_type  = "VnetLocal"
  }
  
  route {
    name           = "internet-nat"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
  
  route {
    name = "vpn-aws"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VirtualNetworkGateway"
  }
}

resource "azurerm_subnet_route_table_association" "ea2_subnet_rt_asso_az" {
  subnet_id      = azurerm_subnet.ea2_pvsubnet.id
  route_table_id = azurerm_route_table.ea2_pvsn_rt_az.id
}

resource "azurerm_route_table" "ea2_gwsn_rt_az" {
  name = "ea2_routetable_gwsubnet"
  location            = azurerm_resource_group.ea2_rg_az.location
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  disable_bgp_route_propagation = false

  route {
    name           = "localroute"
    address_prefix = "10.10.0.0/16"
    next_hop_type  = "VnetLocal"
  }
  
}

resource "azurerm_subnet_route_table_association" "ea2_gwsubnet_rt_asso_az" {
  subnet_id      = azurerm_subnet.gateway.id
  route_table_id = azurerm_route_table.ea2_gwsn_rt_az.id
}
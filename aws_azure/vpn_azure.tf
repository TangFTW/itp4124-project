resource "azurerm_public_ip" "gateway" {
  name                = "aws-vpn-gateway-ip"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  location            = azurerm_resource_group.ea2_rg_az.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "aws" {
  name                = "aws-vpn-gateway"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  location            = azurerm_resource_group.ea2_rg_az.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  sku           = "Basic"
  active_active = false
  enable_bgp    = false

  ip_configuration {
    subnet_id            = azurerm_subnet.gateway.id
    public_ip_address_id = azurerm_public_ip.gateway.id
  }
}

resource "azurerm_local_network_gateway" "aws1" {
  name                = "aws-gateway-1"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  location            = azurerm_resource_group.ea2_rg_az.location

  gateway_address = aws_vpn_connection.azure.tunnel1_address
  address_space   = [aws_vpc.ea2_vpc.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "aws1" {
  name                = "aws-connection-1"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
  location            = azurerm_resource_group.ea2_rg_az.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.aws.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws1.id
  shared_key                 = aws_vpn_connection.azure.tunnel1_preshared_key
}

resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.ea2_vpc.id

  tags = {
    Name = "vpn-gateway"
  }
}

resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.gateway.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "azure-vpn-customer-gateway"
  }
  
  depends_on = [azurerm_virtual_network_gateway.aws]
}

resource "aws_vpn_connection" "azure" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "azure-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "azure" {
  vpn_connection_id      = aws_vpn_connection.azure.id
  destination_cidr_block = azurerm_virtual_network.ea2_vnet.address_space[0]
}

resource "aws_vpn_gateway_route_propagation" "pv" {
  route_table_id = aws_route_table.ea2_vpc_pbrt.id
  vpn_gateway_id = aws_vpn_gateway.main.id
}

resource "aws_vpn_gateway_route_propagation" "pb" {
  route_table_id = aws_route_table.ea2_vpc_rt.id
  vpn_gateway_id = aws_vpn_gateway.main.id
}
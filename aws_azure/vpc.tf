resource "aws_vpc" "ea2_vpc" {
    cidr_block = "10.1.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
    Name = "ea2_vpc"
  }
} 

resource "aws_subnet" "ea2_psn1" {
  vpc_id     = aws_vpc.ea2_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "EA2-PrivateSubnet1"
  }
}

resource "aws_subnet" "ea2_psn2" {
  vpc_id     = aws_vpc.ea2_vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "EA2-PrivateSubnet2"
  }
}

resource "aws_subnet" "ea2_pbsn1" {
  vpc_id     = aws_vpc.ea2_vpc.id
  cidr_block = "10.1.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "EA2-PublicSubnet1"
  }
}


resource "aws_internet_gateway" "ea2_igw" {
    vpc_id = aws_vpc.ea2_vpc.id
    
}


resource "aws_nat_gateway" "ea2_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.ea2_pbsn1.id

  tags = {
    Name = "EA2_gw_NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ea2_igw]
}

resource "aws_eip" "nat_eip" {

}


resource "aws_route_table" "ea2_vpc_pbrt" {
  vpc_id = aws_vpc.ea2_vpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ea2_igw.id
  }
  
  route {
    cidr_block = "10.10.0.0/16"
    gateway_id = aws_vpn_gateway.main.id
  }
  
    tags = {
    Name = "EA2-PublicRouteTable"
  }
}


resource "aws_route_table" "ea2_vpc_rt" {
  vpc_id = aws_vpc.ea2_vpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ea2_nat.id
  }
  
  route {
    cidr_block = "10.10.0.0/16"
    gateway_id = aws_vpn_gateway.main.id
  }
  
    tags = {
    Name = "EA2-RouteTable"
  }
}

resource "aws_route_table_association" "rt_as1" {
  subnet_id      = aws_subnet.ea2_psn1.id
  route_table_id = aws_route_table.ea2_vpc_rt.id
}

resource "aws_route_table_association" "rt_as2" {
  subnet_id      = aws_subnet.ea2_psn2.id
  route_table_id = aws_route_table.ea2_vpc_rt.id
}

resource "aws_route_table_association" "pbrt_as1" {
  subnet_id      = aws_subnet.ea2_pbsn1.id
  route_table_id = aws_route_table.ea2_vpc_pbrt.id
}



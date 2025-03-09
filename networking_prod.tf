resource "aws_vpc" "prod_vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr_block[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod_vpc_public_subnets" {
  count                   = var.create_vpc ? 2 : 0
  vpc_id                  = aws_vpc.prod_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.prod_vpc[0].cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "prod-public-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "prod_vpc_private_subnets" {
  count                   = var.create_vpc ? 2 : 0
  vpc_id                  = aws_vpc.prod_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.prod_vpc[0].cidr_block, 4, count.index + 2)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "prod-private-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "prod_vpc_igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.prod_vpc[0].id
  tags = {
    Name = "prod-vpc-igw"
  }
}

resource "aws_route" "prod_vpc_public_default_route" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.prod_vpc_public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod_vpc_igw[0].id
}

resource "aws_route_table" "prod_vpc_public_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.prod_vpc[0].id
  tags = {
    Name = "prod-public-route-table"
  }
}

resource "aws_route_table_association" "prod_vpc_public_route_table_association" {
  count          = var.create_vpc ? 2 : 0
  subnet_id      = aws_subnet.prod_vpc_public_subnets[count.index].id
  route_table_id = aws_route_table.prod_vpc_public_route_table[0].id
}

resource "aws_route_table" "prod_vpc_private_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.prod_vpc[0].id
  tags = {
    Name = "prod-private-route-table"
  }
}

resource "aws_route" "prod_to_uat_route" {
  count                     = var.create_vpc ? 1 : 0
  route_table_id            = aws_route_table.prod_vpc_private_route_table[0].id
  destination_cidr_block    = aws_vpc.uat_vpc[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_uat_peering[0].id
}

resource "aws_route_table_association" "prod_vpc_private_route_table_association" {
  count          = var.create_vpc ? 2 : 0
  subnet_id      = aws_subnet.prod_vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.prod_vpc_private_route_table[0].id
}
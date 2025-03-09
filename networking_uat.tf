resource "aws_vpc" "uat_vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr_block[1]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "uat-vpc"
  }
}

resource "aws_subnet" "uat_vpc_public_subnets" {
  count                   = var.create_vpc ? 2 : 0
  vpc_id                  = aws_vpc.uat_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.uat_vpc[0].cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "uat-public-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "uat_vpc_private_subnets" {
  count                   = var.create_vpc ? 2 : 0
  vpc_id                  = aws_vpc.uat_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.uat_vpc[0].cidr_block, 4, count.index + 2)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "uat-private-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "uat_vpc_igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.uat_vpc[0].id
  tags = {
    Name = "uat-vpc-igw"
  }
}

resource "aws_route_table" "uat_vpc_public_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.uat_vpc[0].id
  tags = {
    Name = "uat-public-route-table"
  }
}

resource "aws_route" "uat_vpc_public_default_route" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.uat_vpc_public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.uat_vpc_igw[0].id
}

resource "aws_route" "uat_to_prod_route" {
  count                     = var.create_vpc ? 1 : 0
  route_table_id            = aws_route_table.uat_vpc_public_route_table[0].id
  destination_cidr_block    = aws_vpc.prod_vpc[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_uat_peering[0].id
}

resource "aws_route_table_association" "uat_vpc_public_route_table_association" {
  count          = var.create_vpc ? 2 : 0
  subnet_id      = aws_subnet.uat_vpc_public_subnets[count.index].id
  route_table_id = aws_route_table.uat_vpc_public_route_table[0].id
}

resource "aws_route_table" "uat_vpc_private_route_table" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.uat_vpc[0].id
  tags = {
    Name = "uat-private-route-table"
  }
}

resource "aws_route_table_association" "uat_vpc_private_route_table_association" {
  count          = var.create_vpc ? 2 : 0
  subnet_id      = aws_subnet.uat_vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.uat_vpc_private_route_table[0].id
}
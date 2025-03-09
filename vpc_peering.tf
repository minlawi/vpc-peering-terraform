resource "aws_vpc_peering_connection" "prod_uat_peering" {
  count       = var.create_vpc ? 1 : 0
  vpc_id      = aws_vpc.uat_vpc[0].id
  peer_vpc_id = aws_vpc.prod_vpc[0].id
  auto_accept = true

  tags = {
    Name = "prod-uat-peering"
  }
}
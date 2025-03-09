resource "aws_security_group" "prod_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.prod_vpc[0].id
  name   = "prod-sg"
}

resource "aws_security_group_rule" "prod_ingress_ssh" {
  count             = var.create_vpc ? 1 : 0
  security_group_id = aws_security_group.prod_sg[0].id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.uat_vpc[0].cidr_block]
}

resource "aws_security_group_rule" "prod_ingress_icmp" {
  count             = var.create_vpc ? 1 : 0
  security_group_id = aws_security_group.prod_sg[0].id
  type              = "ingress"
  from_port         = 8 // ICMP type 8 is echo request
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.uat_vpc[0].cidr_block]
}

resource "aws_security_group_rule" "prod_egree_all" {
  count             = var.create_vpc ? 1 : 0
  security_group_id = aws_security_group.prod_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
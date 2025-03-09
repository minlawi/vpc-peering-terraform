resource "aws_security_group" "uat_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.uat_vpc[0].id
  name   = "uat-sg"
}

resource "aws_security_group_rule" "uat_ingress_all" {
  count             = var.create_vpc ? 1 : 0
  security_group_id = aws_security_group.uat_sg[0].id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "uat_egress_all" {
  count             = var.create_vpc ? 1 : 0
  security_group_id = aws_security_group.uat_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
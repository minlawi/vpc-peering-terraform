resource "aws_instance" "prod_private_instance" {
  count             = var.create_vpc ? 1 : 0
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.prod_vpc_private_subnets[0].id
  availability_zone = data.aws_availability_zones.available.names[0]
  security_groups   = [aws_security_group.prod_sg[0].id]
  tags = {
    Name = "prod-server-${data.aws_availability_zones.available.names[0]}"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [security_groups]
  }
}
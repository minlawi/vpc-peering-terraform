resource "aws_instance" "uat_public_instance" {
  count             = var.create_vpc ? 1 : 0
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.uat_vpc_public_subnets[1].id
  availability_zone = data.aws_availability_zones.available.names[1]
  security_groups   = [aws_security_group.uat_sg[0].id]
  tags = {
    Name = "uat-server-${data.aws_availability_zones.available.names[1]}"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [security_groups]
  }
}
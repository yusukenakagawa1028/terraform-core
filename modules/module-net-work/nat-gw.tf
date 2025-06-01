resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "subnet-0062e494db7d6c610"
  tags = {
    Name = "nat-gateway"
  }
}

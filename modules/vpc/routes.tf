resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "${var.env}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets
  
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

# Isolated subnets have no route table - completely isolated
resource "aws_route_table" "isolated" {
  count = var.create_isolated_subnets ? 1 : 0
  
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.env}-isolated"
  }
}

resource "aws_route_table_association" "isolated" {
  count = var.create_isolated_subnets ? length(var.azs) : 0
  
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated[0].id
}

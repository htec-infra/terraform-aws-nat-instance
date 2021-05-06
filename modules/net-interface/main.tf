data "aws_subnet" "current" {
  id = var.subnet_id
}

data "aws_subnet" "private" {
  vpc_id = data.aws_subnet.current.vpc_id
  availability_zone = data.aws_subnet.current.availability_zone

  tags = {
    Name = "*private*"
  }
}

data "aws_route_table" "private" {
  subnet_id = data.aws_subnet.private.id
}

resource "aws_eip" "this" {
  count = var.allocate_eip ? 1 : 0
  network_interface = aws_network_interface.this.id
}

resource "aws_network_interface" "this" {
  security_groups   = var.security_groups
  description       = "ENI for NAT instance"
  subnet_id         = var.subnet_id
  source_dest_check = false
  tags              = merge(var.tags,{
    Purpose = "NATInstance"
  })
}

resource "aws_route" "this" {
  route_table_id         = data.aws_route_table.private.id
  network_interface_id   = aws_network_interface.this.id
  destination_cidr_block = "0.0.0.0/0"
}

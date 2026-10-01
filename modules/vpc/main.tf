resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}




resource "aws_subnet" "this" {
    for_each = var.subnets

    vpc_id     = aws_vpc.this.id
    cidr_block = each.value.cidr
    availability_zone = each.value.az

    tags = {
        Name= "${var.name}-${each.key}"
    }
}

resource "aws_internet_gateway" "this" {

    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.name}-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.name}-public-rt"
    }
}

resource "aws_route" "public_deafault" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.name}-private-rt"
    }
}

resource"aws_route_table_association" "this"{
  for_each = var.subnets

  subnet_id      = aws_subnet.this[each.key].id
    route_table_id  = each.value.public ? aws_route_table.public.id : aws_route_table.private.id

}



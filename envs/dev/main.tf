resource "aws_vpc" "app" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app-vpc"
  }
}




locals {
    subnets = {
        public-a  = { cidr = "10.1.0.0/24", az = "us-east-1a", public = true }
        public-b  = { cidr = "10.1.1.0/24", az = "us-east-1b", public = true }
        private-a = { cidr = "10.1.10.0/24", az = "us-east-1a", public = false }
        private-b = { cidr = "10.1.11.0/24", az = "us-east-1b", public = false }
    }
}

resource "aws_subnet" "this" {
    for_each = local.subnets

    vpc_id     = aws_vpc.app.id
    cidr_block = each.value.cidr
    availability_zone = each.value.az

    tags = {
        Name= "app-${each.key}"
    }
}

resource "aws_internet_gateway" "this" {

    vpc_id = aws_vpc.app.id

    tags = {
        Name = "app-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.app.id

    tags = {
        Name = "app-public-rt"
    }
}

resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.app.id

    tags = {
        Name = "app-private-rt"
    }
}

resource"aws_route_table_association" "this"{
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
    route_table_id  = each.value.public ? aws_route_table.public.id : aws_route_table.private.id

}



resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "App tier"
  vpc_id      = aws_vpc.app.id

  tags = {
    Name = "app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_from_vpc" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "10.1.0.0/16"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.app.id
  subnet_ids = [aws_subnet.this["private-a"].id, aws_subnet.this["private-b"].id]

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "10.1.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "10.1.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "app-private-nacl"
  }
}
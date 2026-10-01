module "hub" {
  source = "../../modules/vpc"
  name   = "hub"
  cidr   = "10.0.0.0/16"

  subnets = {
    public-a  = { cidr = "10.0.0.0/24",  az = "us-east-1a", public = true }
    public-b  = { cidr = "10.0.1.0/24",  az = "us-east-1b", public = true }
    private-a = { cidr = "10.0.10.0/24", az = "us-east-1a", public = false }
    private-b = { cidr = "10.0.11.0/24", az = "us-east-1b", public = false }
  }
}

module "app" {
  source = "../../modules/vpc"
  name   = "app"
  cidr   = "10.1.0.0/16"

  subnets = {
    public-a  = { cidr = "10.1.0.0/24",  az = "us-east-1a", public = true }
    public-b  = { cidr = "10.1.1.0/24",  az = "us-east-1b", public = true }
    private-a = { cidr = "10.1.10.0/24", az = "us-east-1a", public = false }
    private-b = { cidr = "10.1.11.0/24", az = "us-east-1b", public = false }
  }
}

module "data" {
  source = "../../modules/vpc"
  name   = "data"
  cidr   = "10.2.0.0/16"

  subnets = {
    public-a  = { cidr = "10.2.0.0/24",  az = "us-east-1a", public = true }
    public-b  = { cidr = "10.2.1.0/24",  az = "us-east-1b", public = true }
    private-a = { cidr = "10.2.10.0/24", az = "us-east-1a", public = false }
    private-b = { cidr = "10.2.11.0/24", az = "us-east-1b", public = false }
  }
}


resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "App tier"
  vpc_id      = module.app.vpc_id

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
  vpc_id     = module.app.vpc_id
  subnet_ids = [module.app.subnet_ids["private-a"], module.app.subnet_ids["private-b"]]

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

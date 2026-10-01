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
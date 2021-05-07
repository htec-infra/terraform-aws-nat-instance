provider "aws" {
  region = local.region
}

locals {
  region = "eu-central-1"

}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "simple-example"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false # This parameter MUST be false
  single_nat_gateway = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

################################################################################
# NAT Instance Module
################################################################################
module "nat_instance" {
  source              = "../../"
  environment         = "Development"
  name                = "Test"
  namespace           = "PoC"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  allocate_elastic_ip = true
}

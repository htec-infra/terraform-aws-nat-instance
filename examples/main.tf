module "nat_instance" {
  source              = "../"
  environment         = "Development"
  name                = "Test"
  namespace           = "PoC"
  vpc_id              = var.vpc_id
  public_subnets      = var.subnets
  allocate_elastic_ip = true
}

#call vpc module
module "vpc" {
  source = "github.com/Priyadarshini916/infrastructure-as-code.git/modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  pub_rt = var.pub_rt
  pvt_rt = var.pvt_rt
  availability_zones = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  user_routes = var.user_routes
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "2.64.0"
  name                         = "${var.namespace}-vpc"
  cidr                         = "172.16.0.0/16"
  azs                          = data.aws_availability_zones.available.names
  private_subnets              = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  public_subnets               = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  database_subnets             = ["172.16.8.0/24", "172.17.9.0/24", "172.16.10.0/24"]
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
}

module "pub_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

module "app_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port            = 8080
    security_groups = [module.pub_sg.security_group.id]
    }, {
    port        = 22
    cidr_blocks = ["10.0.0.0/16"]
  }]
}

module "db_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port            = 3306
    security_groups = [module.app_sg.security_group.id]
  }]
}

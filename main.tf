# only contain resource in this file

# using aws provided module vpc
module "vpc" {
  # online address
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}



module "myapp_ec2" {
  source = "./modules/webserver"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]

  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  pb_key_location = var.pb_key_location
  my_ip = var.my_ip

}


# only contain resource in this file
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc" # apply var inside a string  
  }

}


module "myapp_subnet" {
  # source --> location
  source = "./modules/subnet"

  # passing all parameters
  vpc_id = aws_vpc.myapp_vpc.id
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  subnet_cidr_block = var.subnet_cidr_block
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

}

module "myapp_ec2" {
  source = "./modules/webserver"

  vpc_id = aws_vpc.myapp_vpc.id
  subnet_id = module.myapp_subnet.subnet.id

  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  pb_key_location = var.pb_key_location
  my_ip = var.my_ip

}


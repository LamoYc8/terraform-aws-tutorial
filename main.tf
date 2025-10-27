provider "aws" {

}

variable "vpc_cidr_block" {

}

variable "subnet_cidr_block" {

}

variable "avail_zone" {

}

variable "env_prefix" {

}

variable "my_ip" {

}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc" # apply var inside a string  
  }

}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

}

resource "aws_internet_gateway" "myapp_igw" {
  # create the igw attached to the vpc 
  # use the it inside the route table to handle the outside traffic
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# default route table practice 
# adding routes 
resource "aws_default_route_table" "main_rtb" {
  # any vpc created a default rtb, so no need vpc_id
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

  # adding routes
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
    }
  
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}




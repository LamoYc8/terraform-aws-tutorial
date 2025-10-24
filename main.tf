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

resource "aws_vpc" "myapp_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env_prefix}-vpc" # apply var inside a string  
    }
  
}

resource "aws_subnet" "myapp_subnet_1" {
    vpc_id = aws_vpc.myapp_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name = "${var.env_prefix}-subnet-1"
    }

}

resource "aws_route_table" "myapp_route_table" {
    vpc_id = aws_vpc.myapp_vpc.id # 依赖于vpc
    route {
      # the default route rule will handle all inside vpc traffic
      # no need to specify the default one
      # handle the Internet traffic
      cidr_block = "0.0.0.0/0" # everything from the internet
      gateway_id = aws_internet_gateway.myapp_igw.id
    }

    tags = {
      Name = "${var.env_prefix}-rtb"
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

resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id = aws_subnet.myapp_subnet_1.id 
  route_table_id = aws_route_table.myapp_route_table.id
  
}
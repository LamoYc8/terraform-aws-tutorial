resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

}

resource "aws_internet_gateway" "myapp_igw" {
  # create the igw attached to the vpc 
  # use the it inside the route table to handle the outside traffic
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# default route table practice 
# adding routes 
resource "aws_default_route_table" "main_rtb" {
  # any vpc created a default rtb, so no need vpc_id
  default_route_table_id = var.default_route_table_id
  # adding routes
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id # igw in the same tf file, no need to be parameters
    }
  
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
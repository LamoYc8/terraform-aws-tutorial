provider "aws" {
    
    # the user who must have the permission to conduct the following operations
    # so far set region, access_key, secret_key as env vars under ~/.zshrc file

}

# what we can do with the provider
# working with aws resources
resource "aws_vpc" "dev-vpc" {
    # each block describes one or more infra objects
    cidr_block = "10.0.0.0/16" # 按需控制ip数量, subnets calculator will help with this
    tags = {
      Name = "development",
      vpc_env = "dev"
    }
  
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id # Declarative and coding feature 
    cidr_block = "10.0.10.0/24"
    availability_zone = "ap-southeast-1a"
    tags = {
      Name = "subnet-1-dev"
    
    }
  
}

# create a new resource based on the existing one
data "aws_vpc" "existing" {
  # query the existing resources and components from AWS 
  # resource name + query_result name
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "ap-southeast-1a"
    tags = {
      Name = "subnet-2-default"
    }
}

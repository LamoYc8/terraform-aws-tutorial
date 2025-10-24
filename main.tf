provider "aws" {
    
    # the user who must have the permission to conduct the following operations
    # so far set region, access_key, secret_key as env vars under ~/.zshrc file

}

# adding params for terraform
variable "cider_blocks" {
    description = "cidr blocks for vpc and subnets"
    default = "10.0.10.0/24" # if no params, will set value as the default
    type = list(object({
      name = string
      cidr_block = string
    })) # specify what value types are accepted 
}


# what we can do with the provider
# working with aws resources
resource "aws_vpc" "dev-vpc" {
    # each block describes one or more infra objects
    cidr_block = var.cider_blocks[0].cider_block # 按需控制ip数量, subnets calculator will help with this
    tags = {
      Name = var.cider_blocks[0].name
      vpc_env = "dev"
    }
  
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id # Declarative and coding feature 
    cidr_block = var.cider_blocks[1].cider_block
    availability_zone = "ap-southeast-1a"
    tags = {
      Name = var.cider_blocks[1].name
    
    }
  
}

# create a new resource based on the existing one
data "aws_vpc" "existing" {
  # query the existing resources and components from AWS 
  # resource name + query_result name to expose this result 

  # query conditions: 
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing.id # query and then use it right here
    cidr_block = "172.31.48.0/20"
    availability_zone = "ap-southeast-1a"
    tags = {
      Name = "subnet-2-default"
    }
}

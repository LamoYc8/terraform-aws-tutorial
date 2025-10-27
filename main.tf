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

variable "pb_key_location" {

}

variable "pv_key_location" {

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

# creating firewall rules for the demo vpc
# adding ingres and egress traffic rules
# allowing ssh and nginx access 
resource "aws_security_group" "myapp_sg" {
  name = "allow_ssh&nginx"

  description = "Allow ssh and nginx inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

# latest practice: one CIDR block per rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.myapp_sg.id
  cidr_ipv4         = var.my_ip # ssh will not use proxy, so set it using original ip
  ip_protocol       = "tcp"
  from_port         = 22 # can be a range, if only needs one, then setting from and to the same value
  to_port           = 22

}

resource "aws_vpc_security_group_ingress_rule" "allow_nginx" {
  security_group_id = aws_security_group.myapp_sg.id
  cidr_ipv4         = "0.0.0.0/0" # everyone from the browser to access it
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080

}


resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.myapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # no limitation for protocol
  # semantically equivalent to all ports

}

# instance section 

# fetch ami inform using data source 
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "myapp_ec2" {
  # 2 required args
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro" # based on how much resources we need

  # optional args
  tags = {
    Name = "${var.env_prefix}-server"
  }

  subnet_id              = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true                          # a public ip address to access from the Internet
  key_name                    = aws_key_pair.ssh_key.key_name # using existing key pair to ssh to the server 

  # cmd which will be executed after the server is initiated
  # <<-EOF 模版缩进
  # user_data = file("entry-script.sh")

  # remote exec provisioner
  provisioner "remote-exec" {
    inline = [
      "export ENV=dev",
      "mkdir newdir"
    ]
    # script = file("entry-script.sh") 等效inline, 但file必须事先存在
    # file provisioner 如下
  }

  provisioner "file" {
    source = "entry-script.sh"
    destination = "/home/ec2-user/<file-name>" # 必须指明copy 过去的file name
  }

  # 第3种
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
    # 在本地执行的cmd
  }

  # 显式告诉provisioner如何连接 remote
  # 只用于file and remote-exec
  connection {
    type        = "ssh"
    host        = self.public_ip # self -> the current object [python]
    user        = "ec2-user"
    private_key = file(var.pv_key_location)
  }
}

# aws key pair
resource "aws_key_pair" "ssh_key" {
  key_name   = "key-demo"
  public_key = file(var.pb_key_location) # read the file which contains pb key inform
  # aws will use this pb key to encrypt data

}

# print out the pb ip of the above instance 
output "ec2_pb_ip" {
  value = aws_instance.myapp_ec2.public_ip

}

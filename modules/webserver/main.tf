# creating firewall rules for the demo vpc
# adding ingres and egress traffic rules
# allowing ssh and nginx access 
resource "aws_security_group" "myapp_sg" {
  name = "allow_ssh&nginx"

  description = "Allow ssh and nginx inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

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

  subnet_id              = var.subnet_id 
  # module.module_name.output_name.attr
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true                          # a public ip address to access from the Internet
  key_name                    = aws_key_pair.ssh_key.key_name # using existing key pair to ssh to the server 

  # cmd which will be executed after the server is initiated
  # <<-EOF 模版缩进
  # read cmd from files
  user_data = file("entry-script.sh") # 在root dir下？
}

# aws key pair
resource "aws_key_pair" "ssh_key" {
  key_name   = "key-demo"
  public_key = file(var.pb_key_location) # read the file which contains pb key inform
  # aws will use this pb key to encrypt data

}

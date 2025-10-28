# print out the pb ip of the above instance 
output "ec2_pb_ip" {
  value = aws_instance.myapp_ec2.public_ip
  
}

output "aws_ami_id" {
    value = data.aws_ami.latest_amazon_linux.id
  
}
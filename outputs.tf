# print out the pb ip of the above instance 
output "ec2_pb_ip" {
  value = module.myapp_ec2.ec2_server.associate_public_ip_address
  
}

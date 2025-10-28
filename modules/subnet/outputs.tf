output "subnet" {
    # export the child module subnet, so that parent module could use it
    value = aws_subnet.myapp_subnet_1
  
}
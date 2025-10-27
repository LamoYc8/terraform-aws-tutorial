#!/bin/bash
sudo yum update -y && sudo yum install -y docker 
echo 'Done updating and installing docker'
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
echo 'adding ec2-user to docker group'
docker run -p 8080:80 nginx
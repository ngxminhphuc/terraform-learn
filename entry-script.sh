#!/bin/bash
sudo yum update -y && sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
docker run -p 8080:8080 nginx

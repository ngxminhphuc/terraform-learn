terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.78.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "avail_zone" {}

variable "env_prefix" {}

variable "local_cidr_ipv4" {}

variable "local_public_key_location" {}

resource "aws_vpc" "crew-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-crew-app-vpc"
  }
}

resource "aws_subnet" "crew-app-subnet-1" {
  vpc_id            = aws_vpc.crew-app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-crew-app-subnet-1"
  }
}

resource "aws_default_route_table" "crew-app-main-rtb" {
  default_route_table_id = aws_vpc.crew-app-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.crew-app-igw.id
  }

  tags = {
    "Name" = "${var.env_prefix}-crew-app-main-rtb"
  }
}

resource "aws_internet_gateway" "crew-app-igw" {
  vpc_id = aws_vpc.crew-app-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-crew-app-igw"
  }
}

resource "aws_security_group" "crew-app-sg" {
  name   = "crew-app-sg"
  vpc_id = aws_vpc.crew-app-vpc.id

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-allow-ssh" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.local_cidr_ipv4

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-allow-http" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-allow-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-allow-https" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-allow-https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-custom-tcp" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-custom-tcp"
  }
}

resource "aws_vpc_security_group_egress_rule" "crew-app-sg-egress-all" {
  security_group_id = aws_security_group.crew-app-sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-egress-all"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.env_prefix}-crew-app-server-key"
  public_key = file(var.local_public_key_location)
}

resource "aws_instance" "crew-app-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.crew-app-subnet-1.id
  vpc_security_group_ids = [aws_security_group.crew-app-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  user_data                   = file("entry-script.sh")
  user_data_replace_on_change = true

  tags = {
    "Name" = "${var.env_prefix}-crew-app-server"
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
  value = aws_instance.crew-app-server.public_ip
}

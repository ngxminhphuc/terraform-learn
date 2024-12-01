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

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-ingress-1" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.local_cidr_ipv4

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-ingress-1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crew-app-sg-ingress-2" {
  security_group_id = aws_security_group.crew-app-sg.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-ingress-2"
  }
}

resource "aws_vpc_security_group_egress_rule" "crew-app-sg-egress-1" {
  security_group_id = aws_security_group.crew-app-sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "${var.env_prefix}-crew-app-sg-egress-1"
  }
}

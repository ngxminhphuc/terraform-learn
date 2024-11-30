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

resource "aws_route_table" "crew-app-route-table" {
  vpc_id = aws_vpc.crew-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.crew-app-igw.id
  }

  tags = {
    "Name" = "${var.env_prefix}-crew-app-rtb"
  }
}

resource "aws_internet_gateway" "crew-app-igw" {
  vpc_id = aws_vpc.crew-app-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-crew-app-igw"
  }
}

resource "aws_route_table_association" "crew-app-rtb-assoc-subnet-1" {
  subnet_id = aws_subnet.crew-app-subnet-1.id
  route_table_id = aws_route_table.crew-app-route-table.id
}

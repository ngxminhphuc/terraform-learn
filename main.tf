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

variable "environment" {
  description = "deployment environment"
  type        = string
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  type        = string
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
}

variable "avail_zone" {
  
}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "subnet-1-dev"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet-1-id" {
  value = aws_subnet.dev-subnet-1.id
}

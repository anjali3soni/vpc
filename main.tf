terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-sub"
  }
}

resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public-sub"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "pub-sub" {
  route_table_id = aws_route_table.my-route.id
  subnet_id      = aws_subnet.public-sub.id
}
resource "aws_eip" "my-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my-ngw" {
  subnet_id = aws_subnet.public-sub.id
  allocation_id = aws_eip.my-eip.id
  tags = {
    Name = "my-ngw"
  }
  depends_on = [ aws_internet_gateway.my-igw ]
}

resource "aws_instance" "my-inst" {
  ami = "ami-0862be96e41dcbf74"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-sub.id
  tags = {
    Name = "my-inst"
  }
}


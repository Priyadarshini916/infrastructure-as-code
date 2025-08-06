provider "aws" {
  region = "us-east-1"
}

#create a vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.81.0.0/16"
  tags = {
    Name = "prod-vpc"
  }
}
#create igw
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}
#create rt
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-rt"
  }
}
#create a private subnet

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
  map_public_ip_on_launch = false # Ensures it's a private subnet

  tags = {
    Name = "private-subnet-${count.index}"
  }
}
variable "private_subnet_cidrs" {
  description = "list of cidr blocks for private subnets"
  type = list(string)
  default = [ "10.81.1.0/24", "10.81.2.0/24" ]
}


#create public subnets
    resource "aws_subnet" "public" {
      count                   = var.public_subnet_count
      vpc_id                  = aws_vpc.prod-vpc.id
      cidr_block              = var.public_subnet_cidrs[count.index]
      availability_zone       = var.availability_zones[count.index]
      map_public_ip_on_launch = true # Essential for public subnets

      tags = {
        Name = "public-subnet-${count.index}"
      }
    }
variable "public_subnet_count" {
  type = number
  default = 2
}
variable "public_subnet_cidrs" {
  description = "a list of cidr blocks for public subnet"
  type = list(string)
  default = ["10.81.3.0/24", "10.81.4.0/24"]
}
variable "availability_zones" {
   description = "A list of availability zones to deploy subnets into."
      type        = list(string)
      default     = ["us-east-1a", "us-east-1b"]
    }


#create rt association

resource "aws_route_table_association" "prod-rt-association" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.prod-rt.id
}
#create nat-gateway
resource "aws_nat_gateway" "prod-natgateway" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id

  tags = {
    Name = "prod-nategateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prod-igw]
}
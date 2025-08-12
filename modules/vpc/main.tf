#create a vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "prod-vpc"
  }
}
#create igw

resource "aws_internet_gateway" "prod-igw" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}
#create public rt
resource "aws_route_table" "prod-rt" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.prod-vpc.id

  dynamic "route" {
    for_each = local.has_public_subnets ? [1] : [] # Iterate once if public subnets exist, otherwise zero times
    content {
      cidr_block = var.pub_rt
      gateway_id = aws_internet_gateway.prod-igw[0].id # Reference your NAT Gateway
    }
  }

  tags = {
    Name = "prod-rt"
  }
}
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
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

#create public subnets
    resource "aws_subnet" "public" {
      count                   = length(var.public_subnet_cidrs)
      vpc_id                  = aws_vpc.prod-vpc.id
      cidr_block              = var.public_subnet_cidrs[count.index]
      availability_zone       = var.availability_zones[count.index]
      map_public_ip_on_launch = true # Essential for public subnets

      tags = {
        Name = "public-subnet-${count.index}"
      }
    }

#create rt association

resource "aws_route_table_association" "prod-rt-association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.prod-rt[count.index].id
}
#create nat-gateway
resource "aws_nat_gateway" "prod-natgateway" {
  count          = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.eip-prod[count.index].id
  subnet_id      = aws_subnet.public[count.index].id

  tags = {
    Name = "prod-nategateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prod-igw]
}


#create eip for nat-gateway

resource "aws_eip" "eip-prod" {
  count = length(var.public_subnet_cidrs)

}

#conditional creation with dynamic block (to avoid route creation of natgateway in pvt rt when no public sn are created)


locals {
  # Assuming 'public_subnet_ids' is a list of IDs of your public subnets
  # If the list is empty, no public subnets exist.
  has_public_subnets = length(var.public_subnet_cidrs) > 0
}

resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnet_cidrs) 
  vpc_id = aws_vpc.prod-vpc.id

  dynamic "route" {
    for_each = local.has_public_subnets ? [count.index] : [] # Iterate once if public subnets exist, otherwise zero times
    content {
      cidr_block = var.pvt_rt
      nat_gateway_id = aws_nat_gateway.prod-natgateway[count.index].id # Reference your NAT Gateway
    }
  }

  tags = {
    Name = "Private-Route-Table"
  }
}
#create additional routes for different users using variables

resource "aws_route" "user_specific_routes" {
  for_each = {for rtb_id, routes in var.user_routes : rtb_id => routes}

  route_table_id        = each.key
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id = try(each.value.gateway_id, null )
  nat_gateway_id = try(each.value.nat_gateway_id, null)
}


#######
# VPC #
#######
resource "aws_vpc" "main" {
  cidr_block = var.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}


##################
# Public Subnets #
##################
resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr, 2, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count = 2

  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


###################
# Private Subnets #
###################
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr, 1, 1)

  map_public_ip_on_launch = true

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

data "aws_region" "current" {}

locals {
  services = {
    "ec2messages": {
      "name": "com.amazonaws.${data.aws_region.current.region}.ec2messages",
      "type": "Interface"
    },
    "ssm" : {
      "name" : "com.amazonaws.${data.aws_region.current.region}.ssm",
      "type": "Interface"
    },
    "ssmmessages" : {
      "name" : "com.amazonaws.${data.aws_region.current.region}.ssmmessages",
      "type": "Interface"
    }
    "s3" : {
      "name" : "com.amazonaws.${data.aws_region.current.region}.s3",
      "type": "Gateway"
    }
    "ecr-dkr" : {
      "name" : "com.amazonaws.${data.aws_region.current.region}.ecr.dkr",
      "type": "Interface"
    }
    "ecr-api" : {
      "name" : "com.amazonaws.${data.aws_region.current.region}.ecr.api",
      "type": "Interface"
    }
  }
}

resource "aws_vpc_endpoint" "endpoints" {
  for_each = local.services

  vpc_id              = aws_vpc.main.id
  service_name        = each.value.name
  vpc_endpoint_type   = each.value.type
  security_group_ids  = each.value.type == "Interface" ? [aws_security_group.endpoints.id] : null
  route_table_ids     = each.value.type == "Gateway" ? [aws_route_table.private_route_table.id] : null
  private_dns_enabled = each.value.type == "Interface" ? true : null
  ip_address_type     = "ipv4"
  subnet_ids          = each.value.type == "Interface" ? [aws_subnet.private_subnet.id] : null

  tags = {
    Name = "${each.key}-endpoint"
  }
}

resource "aws_security_group" "endpoints" {
  name        = "vpc-endpoints"
  description = "Allow traffic to/from vpc endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints"
  }
}

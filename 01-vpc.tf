

# 1 - Create Network stack
#   Create network stack for your infrastructure with the following resources:
#   VPC:
#     name=cloudx, cidr=10.10.0.0/16, enable_dns_support=true, enable_dns_hostnames=true
#   3 x Public subnets:
#     name=public_a, cidr=10.10.1.0/24, az=a
#     name=public_b, cidr=10.10.2.0/24, az=b
#     name=public_c, cidr=10.10.3.0/24, az=c
#   3 x Private subnets:
#     name=private_a, cidr=10.10.10.0/24, az=a
#     name=private_b, cidr=10.10.11.0/24, az=b
#     name=private_c, cidr=10.10.12.0/24, az=c
#   3 x Database subnets(private)
#     name=private_db_a, cidr=10.10.20.0/24, az=a
#     name=private_db_b, cidr=10.10.21.0/24, az=b
#     name=private_db_c, cidr=10.10.22.0/24, az=c
#   Internet gateway (name=cloudx-igw) and attach it to appropriate VPC
#   Routing table to bind Internet gateway with the Public subnets (name=public_rt)
#   Routing table and attach it with the Private subnets (name=private_rt)

resource "aws_vpc" "cloudx-vpc" {
  cidr_block              = "10.10.0.0/16"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Name = "cloudx"
  }
}

resource "aws_route_table" "cloudx-vpc-main-rt-igw" {
  vpc_id         = aws_vpc.cloudx-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }
  tags = {
    Name = "cloudx-vpc-main-rt-igw"
  }
}


resource "aws_main_route_table_association" "cloudx-vpc-main-rt" {
  vpc_id         = aws_vpc.cloudx-vpc.id
  route_table_id = aws_route_table.cloudx-vpc-main-rt-igw.id
}


## Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.1.0/24"
  availability_zone   = "eu-central-1a"
  tags                = {
  Name                = "public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.2.0/24"
  availability_zone   = "eu-central-1b"
  tags                = {
  Name                = "public_b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.3.0/24"
  availability_zone   = "eu-central-1c"
  tags                = {
  Name                = "public_c"
  }
}

## Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.10.0/24"
  availability_zone   = "eu-central-1a"
  tags                = {
  Name                = "private_a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.11.0/24"
  availability_zone   = "eu-central-1b"
  tags                = {
  Name                = "private_b"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.12.0/24"
  availability_zone   = "eu-central-1c"
  tags                = {
  Name                = "private_c"
  }
}

## Private DB Subnets
resource "aws_subnet" "private_db_a" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.20.0/24"
  availability_zone   = "eu-central-1a"
  tags                = {
  Name                = "private_db_a"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.21.0/24"
  availability_zone   = "eu-central-1b"
  tags                = {
  Name                = "private_db_b"
  }
}

resource "aws_subnet" "private_db_c" {
  vpc_id              = aws_vpc.cloudx-vpc.id
  cidr_block          = "10.10.22.0/24"
  availability_zone   = "eu-central-1c"
  tags                = {
  Name                = "private_db_c"
  }
}




####### Internet Gateway

resource "aws_internet_gateway" "cloudx-igw" {
  vpc_id = aws_vpc.cloudx-vpc.id

  tags = {
    Name = "cloudx-igw"
  }
}


resource "aws_eip" "private_a_eip" {
  vpc = true
  tags = {
    Name = "private_a_eip"
  }
}
resource "aws_nat_gateway" "private_a_natgw" {
  allocation_id = aws_eip.private_a_eip.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name = "private_a_natgw"
  }
  depends_on = [ aws_eip.private_a_eip]
}
resource "aws_eip" "private_b_eip" {
  vpc = true
  tags = {
    Name = "private_b_eip"
  }
}
resource "aws_nat_gateway" "private_b_natgw" {
  allocation_id = aws_eip.private_b_eip.id
  subnet_id     = aws_subnet.private_b.id
  tags = {
    Name = "private_b_natgw"
  }
  depends_on = [aws_eip.private_b_eip]
}
resource "aws_eip" "private_c_eip" {
  vpc = true
  tags = {
    Name = "private_c_eip"
  }
}
resource "aws_nat_gateway" "private_c_natgw" {
  allocation_id = aws_eip.private_c_eip.id
  subnet_id     = aws_subnet.public_c.id
  tags = {
    Name = "private_c_natgw"
  }
  depends_on = [aws_eip.private_c_eip]
}


######### Public Routes


resource "aws_route_table" "public_rt_a" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "public_rt_a"
  }
}

resource "aws_route_table" "public_rt_b" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "public_rt_b"
  }
}

resource "aws_route_table" "public_rt_c" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "public_rt_c"
  }
}
# Public Route Assoc
resource "aws_route_table_association" "pub_sub_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt_a.id
}

resource "aws_route_table_association" "pub_sub_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt_b.id
}

resource "aws_route_table_association" "pub_sub_assoc_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt_c.id
}

######## private Routes

resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "private_rt_a"
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id    
  }

  tags = {
    Name = "private_rt_b"
  }
}

resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "private_rt_c"
  }
}

# Private Route Assoc
resource "aws_route_table_association" "prv_sub_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "prv_sub_assoc_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

resource "aws_route_table_association" "prv_sub_assoc_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt_c.id
}

######## private DB Routes
resource "aws_route_table" "private_rt_db_a" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "private_rt_db_a"
  }
}

resource "aws_route_table" "private_rt_db_b" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "private_rt_db_b"
  }
}

resource "aws_route_table" "private_rt_db_c" {
  vpc_id = aws_vpc.cloudx-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  tags = {
    Name = "private_rt_db_c"
  }
}

# Private DB Route Assoc
resource "aws_route_table_association" "prv_db_sub_assoc_a" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private_rt_db_a.id
}

resource "aws_route_table_association" "prv_db_sub_assoc_b" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private_rt_db_b.id
}

resource "aws_route_table_association" "prv_db_sub_assoc_c" {
  subnet_id      = aws_subnet.private_db_c.id
  route_table_id = aws_route_table.private_rt_db_c.id
}

##VPC-Endpoints

resource "aws_vpc_endpoint" "ghost-dkr" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-ecr-api" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-ssm" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#

resource "aws_vpc_endpoint" "ghost-efs" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.elasticfilesystem"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-s3" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type     = "Interface"
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-s3ap" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.s3-global.accesspoint"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-s3gw" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type     = "Gateway"
  route_table_ids       = [
    aws_route_table.private_rt_a.id,
    aws_route_table.private_rt_b.id,
    aws_route_table.private_rt_c.id,
  ]
}

#
resource "aws_vpc_endpoint" "ghost-logs" {
  vpc_id                = aws_vpc.cloudx-vpc.id
  service_name          = "com.amazonaws.eu-central-1.logs"
  vpc_endpoint_type     = "Interface"
  private_dns_enabled   = true
  security_group_ids    = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids            = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

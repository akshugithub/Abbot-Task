# creating vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# create internet gateway and attach to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# creating public subnet
resource "aws_subnet" "pubsub" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pubsub_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet"
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.pubroute_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

# associate public subnet to "public route table"
resource "aws_route_table_association" "public_subnet_rt_association" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.public_route_table.id
}


# creating private subnet
resource "aws_subnet" "privsub" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.privsub_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet"
  }
}

# create route table and add private route
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.privroute_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# associate private subnet to "private route table"
resource "aws_route_table_association" "private_subnet_rt_association" {
  subnet_id      = aws_subnet.privsub.id
  route_table_id = aws_route_table.private_route_table.id
}

# creating security groups
resource "aws_security_group" "securitygroup" {
  name        = "securitygroup"
  description = "security group for EC2 Instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "${var.project_name}-${var.environment}-securitygroup"
  }
} 

# creating EC2 instance
resource "aws_instance" "ec2_instance" {

    ami = var.ami_id
    instance_type          = var.web_instance_type
    vpc_security_group_ids = [aws_security_group.securitygroup.id]
    subnet_id              = aws_subnet.pubsub.id
    key_name               = var.key_name 
    associate_public_ip_address = true
}

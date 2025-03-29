provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Create a VPC
resource "aws_vpc" "hcl_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hcl_vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.hcl_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "public_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hcl_vpc.id

  tags = {
    Name = "hcl_igw"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.hcl_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main_route_table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Group for SSH and HTTP
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.hcl_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "hcl-key"  
  security_groups = [aws_security_group.sg.name]

  tags = {
    Name = "web-server"
  }

 # creat ECR repository

resource "aws_ecr_repository" "hcl_repo" {
  name                 = "hcl-ecr-repository" 
  image_scanning_configuration {
    scan_on_push = true  
  }

  image_tag_mutability = "MUTABLE"  
}

output "repository_url" {
  value = aws_ecr_repository.example_repo.repository_url
  description = "The URL of the created ECR repository"
}

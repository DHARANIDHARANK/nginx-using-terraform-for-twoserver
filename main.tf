provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

# VPC for us-east-2
resource "aws_vpc" "vpc_east" {
  provider    = aws.us_east_2
  cidr_block  = "10.0.0.0/16"

  tags = {
    Name = "Project VPC East"
  }
}

# VPC for us-west-2
resource "aws_vpc" "vpc_west" {
  provider    = aws.us_west_2
  cidr_block  = "10.0.0.0/16"

  tags = {
    Name = "Project VPC West"
  }
}

# Internet Gateway for us-east-2
resource "aws_internet_gateway" "igw_east" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.vpc_east.id

  tags = {
    Name = "Project IGW East"
  }
}

# Internet Gateway for us-west-2
resource "aws_internet_gateway" "igw_west" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_west.id

  tags = {
    Name = "Project IGW West"
  }
}

# Route Table for us-east-2
resource "aws_route_table" "rt_east" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.vpc_east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east.id
  }

  tags = {
    Name = "Project RT East"
  }
}

# Route Table for us-west-2
resource "aws_route_table" "rt_west" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_west.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_west.id
  }

  tags = {
    Name = "Project RT West"
  }
}

# Subnet for us-east-2
resource "aws_subnet" "subnet_east" {
  provider          = aws.us_east_2
  vpc_id            = aws_vpc.vpc_east.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Project Subnet East"
  }
}

# Subnet for us-west-2
resource "aws_subnet" "subnet_west" {
  provider          = aws.us_west_2
  vpc_id            = aws_vpc.vpc_west.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Project Subnet West"
  }
}

# Associate Route Table with Subnet for us-east-2
resource "aws_route_table_association" "rta_east" {
  provider        = aws.us_east_2
  subnet_id       = aws_subnet.subnet_east.id
  route_table_id  = aws_route_table.rt_east.id
}

# Associate Route Table with Subnet for us-west-2
resource "aws_route_table_association" "rta_west" {
  provider        = aws.us_west_2
  subnet_id       = aws_subnet.subnet_west.id
  route_table_id  = aws_route_table.rt_west.id
}

# Security Group for us-east-2
resource "aws_security_group" "allow_http_east" {
  provider = aws.us_east_2
  vpc_id   = aws_vpc.vpc_east.id
  name     = "allow_http_east"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "allow_http_east"
  }
}

# Security Group for us-west-2
resource "aws_security_group" "allow_http_west" {
  provider = aws.us_west_2
  vpc_id   = aws_vpc.vpc_west.id
  name     = "allow_http_west"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "allow_http_west"
  }
}

# EC2 Instance in us-east-2
resource "aws_instance" "web_us_east" {
  provider                     = aws.us_east_2
  ami                          = "ami-0c55b159cbfafe1f0" # Use a valid AMI ID
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.subnet_east.id
  security_groups           = [aws_security_group.allow_http_east.id]
  associate_public_ip_address  = true

  tags = {
    Name = "web-server-us-east"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "This is nginx from server side in us-east-2" | sudo tee /usr/share/nginx/html/index.html
              EOF
}

# EC2 Instance in us-west-2
resource "aws_instance" "web_us_west" {
  provider                     = aws.us_west_2
  ami                          = "ami-0e34e7b9ca0ace12d" # Use a valid AMI ID
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.subnet_west.id
  security_groups           = [aws_security_group.allow_http_west.id]
  associate_public_ip_address  = true

  tags = {
    Name = "web-server-us-west"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "This is nginx from server side in us-west-2" | sudo tee /usr/share/nginx/html/index.html
              EOF
}

# Outputs for public IP addresses
output "web_us_east_public_ip" {
  value = aws_instance.web_us_east.public_ip
}

output "web_us_west_public_ip" {
  value = aws_instance.web_us_west.public_ip
}

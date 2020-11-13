terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  access_key = ""
  secret_key = ""
}

# Create a VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id

}
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev"
  }
}
resource "aws_subnet" "subnet-1"{
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = "10.0.1.0/24"
  #cidr_block = var.subnet_prefix
  #cidr_block = var.subnet_prefix[0]
  #cidr_block = var.subnet_prefix[1]
  #cidr_block = var.subnet_prefix[0].cidr_block
  #cidr_block = var.subnet_prefix[1].cidr_block

  availability_zone = "ap-south-1a"
  tags = {
    Name = "dev-subnet"
   # Name = var.subnet_prefix[0].name
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.dev-route-table.id
}
resource "aws_security_group" "allow-web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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
    Name = "allow_web"
  }
}
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]

   }
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_instance" "web-server-instance"{
  ami = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "main-key"

  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-eof
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -< 'Web Server' > /var/www/html/index.html
              eof
  tags = {
      name = "web server"
  }
}

output "server_public_ip" {
  value = "aws_eip.1.public_ip"
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "server_id" {
  value = aws_instance.web-server-instance.id
}

variable "subnet_prefix" {
  description = "CIDR block for the subnet"
 # default = "10.0.60.0/24"
  type = string
}

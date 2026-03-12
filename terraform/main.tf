terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "my_ip" {
  description = "Secure IP address passed from Jenkins vault"
  type        = string
}

provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------
# 1. SECURITY GROUP
# ------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "lendenclub_app_sg"
  description = "Secure security group for deepfake app"

  ingress {
    description = "SSH from my personal laptop only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] 
  }

  ingress {
    description = "Flask Application Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic to internal network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

# ------------------------------------------------------
# 2. VIRTUAL MACHINE / COMPUTE INSTANCE
# ------------------------------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"              

  key_name      = "lendenclub-key"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name        = "LenDenClub-Mocked-Deepfake-App"
    Environment = "DevSecOps-Assignment"
  }
}

# ------------------------------------------------------
# 3. OUTPUTS
# ------------------------------------------------------
output "server_public_ip" {
  description = "The Public IP address of the deployed web server"
  value       = aws_instance.app_server.public_ip
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Keys will be passed via Jenkins / Environment Variables later
}

# ------------------------------------------------------
# 1. SECURITY GROUP (PATCHED FOR TRIVY COMPLIANCE)
# ------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "lendenclub_app_sg"
  description = "Secure security group for deepfake app"

  ingress {
    description = "SSH from internal network only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
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
# 2. VIRTUAL MACHINE / COMPUTE INSTANCE (PATCHED)
# ------------------------------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Standard Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"              # AWS Free Tier eligible (1 vCPU, 1GB RAM)

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
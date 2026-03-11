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
# 1. SECURITY GROUP (INTENTIONAL VULNERABILITY INCLUDED)
# ------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "lendenclub_app_sg"
  description = "Security group for deepfake app with intentional flaws"

  # 🚨 INTENTIONAL VULNERABILITY 1: SSH open to the entire internet (0.0.0.0/0)
  # Trivy will flag this as a HIGH/CRITICAL issue during the pipeline scan.
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound traffic for your Flask web app (Port 3000)
  ingress {
    description = "Flask Application Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (standard practice)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------
# 2. VIRTUAL MACHINE / COMPUTE INSTANCE
# ------------------------------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Standard Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"              # AWS Free Tier eligible (1 vCPU, 1GB RAM)

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "LenDenClub-Mocked-Deepfake-App"
    Environment = "DevSecOps-Assignment"
  }
}

# ------------------------------------------------------
# 3. OUTPUTS (To grab the Public IP easily)
# ------------------------------------------------------
output "server_public_ip" {
  description = "The Public IP address of the deployed web server"
  value       = aws_instance.app_server.public_ip
}
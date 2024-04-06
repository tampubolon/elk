# Variables
variable "ec2_yaml_file" {
  default = "ec2.yaml"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-08e4b984abde34a4f"  # Ubuntu 20.04 LTS
}

# Load YAML file
locals {
  ec2_instances = yamldecode(file(var.ec2_yaml_file))
}

# IAM role
resource "aws_iam_role" "ec2_role" {
  name               = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Security group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Security group for EC2 instances"
  vpc_id      = "vpc-078d43214673a89d4"  # Replace with your VPC ID

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "ec2_instances" {
  count = length(local.ec2_instances)

  ami           = var.ami
  instance_type = local.ec2_instances[count.index].instance_type
  subnet_id     = local.ec2_instances[count.index].subnet_id
  key_name      = "elasticsearch"  # Assigning SSH key
  associate_public_ip_address = true  # Enable Public IPv4 DNS

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ec2_instances[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  # User data for Ubuntu instances
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt upgrade -y
              EOF
}

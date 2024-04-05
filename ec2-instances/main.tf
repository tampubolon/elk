# Variables
variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-06c4be2792f419b7b"  # Ubuntu 20.04 LTS
}

variable "subnet_ids" {
  type        = list(string)
  default     = ["subnet-0aeee14cbbe042068", "subnet-07ce11cc724dff767", "subnet-08a9195eaa0a5b4bb"]
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
  count         = 3
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "EC2 Instance ${count.index + 1}"
  }

  security_groups = [aws_security_group.ec2_security_group.name]

  # User data for Ubuntu instances
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt upgrade -y
              EOF
}

variable "ec2_yaml_file" {
  description = "Path to the YAML file describing EC2 instances"
  type        = string
  default     = "ec2.yaml"
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-08e4b984abde34a4f" # Ubuntu 20.04 LTS
}

locals {
  vpc_id        = "vpc-078d43214673a89d4"
  ec2_instances = yamldecode(file(var.ec2_yaml_file))

  public_subnet_count  = length(tolist(data.aws_subnet_ids.public.ids))
  private_subnet_count = length(tolist(data.aws_subnet_ids.private.ids))

  public_subnet_indices  = range(local.public_subnet_count)
  private_subnet_indices = range(local.private_subnet_count)

  public_instance_count  = length(local.ec2_instances.public)
  private_instance_count = length(local.ec2_instances.private)
}

data "aws_subnet_ids" "public" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:type"
    values = ["public"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:type"
    values = ["private"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "public_ec2_instances" {
  count = local.public_instance_count

  ami                         = var.ami
  instance_type               = local.ec2_instances.public[count.index].instance_type
  subnet_id                   = element(tolist(data.aws_subnet_ids.public.ids), local.public_subnet_indices[count.index % local.public_subnet_count])
  key_name                    = "elasticsearch"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ec2_instances.public[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.public_ec2_security_group.id]

  user_data = templatefile("${path.module}/user_data.tpl", {
    elasticsearch = local.ec2_instances.public[count.index].elasticsearch
  })
}

resource "aws_instance" "private_ec2_instances" {
  count = local.private_instance_count

  ami                         = var.ami
  instance_type               = local.ec2_instances.private[count.index].instance_type
  subnet_id                   = element(tolist(data.aws_subnet_ids.private.ids), local.private_subnet_indices[count.index % local.private_subnet_count])
  key_name                    = "elasticsearch"
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ec2_instances.private[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.private_ec2_security_group.id]

  user_data = templatefile("${path.module}/user_data.tpl", {
    elasticsearch = local.ec2_instances.private[count.index].elasticsearch
  })
}
provider "aws" {
  region = var.region
  profile = "default"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "app_sg" {
  name_prefix = "divops-sg"
  description = "Security group for DevOps application"
  vpc_id      = data.aws_vpc.default.id

  # SSH 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Frontend application
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # GenAI API
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal communication between roles
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "divops-security-group"
  }
}
resource "aws_instance" "app" {
  for_each = toset(var.roles)

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.app_sg.id]

  tags = {
    Name = "${each.key}"
    Role = each.key
  }
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
[frontend]
${aws_instance.app["frontend"].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}

[backend]
${aws_instance.app["backend"].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}

[genai]
${aws_instance.app["genai"].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT
  filename = "${path.module}/hosts.ini"
}

output "instance_ips" {
  value = {
    for role, instance in aws_instance.app : role => instance.public_ip
  }
}
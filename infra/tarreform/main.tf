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

resource "aws_instance" "app" {
  for_each = toset(var.roles)

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${each.key}"
    Role = each.key
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    frontend_ip = aws_instance.app["frontend"].public_ip
    backend_ip  = aws_instance.app["backend"].public_ip
    genai_ip    = aws_instance.app["genai"].public_ip
    ssh_key     = var.ssh_private_key_path
  })
  filename = "${path.module}/hosts.ini"
}

output "instance_ips" {
  value = {
    for role, instance in aws_instance.app : role => instance.public_ip
  }
}
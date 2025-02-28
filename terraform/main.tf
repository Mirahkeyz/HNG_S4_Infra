provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  key_name = var.key_name
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "to-do-app-server"
  }

}

resource "aws_security_group" "app_sg" {
  name_prefix = "todo-app-sg-"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [
    aws_instance.app_server,
  ]

  # Add triggers to ensure ansible runs when instance or IP changes
  triggers = {
    instance_id = aws_instance.app_server.id
  }
}
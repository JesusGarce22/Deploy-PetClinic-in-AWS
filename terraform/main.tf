provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "key_pair" {
  key_name   = "my-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Permitir SSH y puerto 8080"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir SSH desde cualquier IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acceso al puerto 8080
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker ec2-user

    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    sudo apt install unzip
    sudo snap install docker
    sudo apt install docker-compose
  EOF

  tags = {
    Name = "Terraform-EC2"
  }
}
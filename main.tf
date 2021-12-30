data "aws_vpc" "main" {
  id = "vpc-bc59d8d7"
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "Permitir trafico HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Permitir trafico SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.my_ip_with_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
  }]

  egress {
    description      = "Permitir trafico de salida"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "allow_tls"
  }
}

data "template_file" "user_data" {
  
  template = file("${abspath(path.module)}/userdata.yaml")
}
provider "aws" {
  alias  = "east"
  region = "us-east-2"
}

data "aws_ami" "st-amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  provider    = aws.east

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBT3cXMihfciUjvX5CnHCnJzLsTYPJGOIft4HAQEggF root@terraform"
}


resource "aws_instance" "my_server" {
  #ami                    = "ami-056b1936002ca8ede"
  ami                    = data.aws_ami.st-amazon-linux-2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  /*
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }*/

  /*
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
    ]

  }*/

  provisioner "file" {
    content     = "Mars"
    destination = "/home/ec2-user/barsoon.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("/root/.ssh/id_ed25519")
    }
  }

  /*connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/root/.ssh/id_ed25519")
  }*/


  tags = {
    Name   = var.server_name
    Author = "Larry Saldaña"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  
}

terraform { 
  cloud { 
    
    organization = "ABDELBAGUI" 

    workspaces { 
      name = "abdel_workspace" 
    } 
  } 
}

# Déclaration du VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "abdel_main-vpc"
  }
}

# Création d'une passerelle Internet et attachement au VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-gateway"
  }
}

# Création d'un sous-réseau
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-subnet"
  }
}

# Création d'une table de routage et association avec le sous-réseau
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# Création d'un groupe de sécurité autorisant SSH et HTTP
resource "aws_security_group" "allow_ssh_web" {
  name_prefix = "allow_ssh_web"
  vpc_id      = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_web"
  }
}

# Création de l'instance EC2 sans l'Elastic IP
resource "aws_instance" "vm" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  key_name               = "terraform_cle"
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
  subnet_id              = aws_subnet.main.id
  tags = {
    Name = "Abdel_EC2_hassan"
  }

  # Provisioner pour installer et démarrer Nginx
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./terraform_cle.pem")
      host        = aws_instance.vm.public_ip
    }
  }

  # Vous pouvez omettre 'depends_on' pour éviter les cycles
}

# Allocation de l'Elastic IP
resource "aws_eip" "ip" {
  domain = "vpc"
}

# Association de l'Elastic IP à l'instance EC2 après la création de l'instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.ip.id
  # Assurez-vous que l'association se fait après la création des ressources
  depends_on = [aws_instance.vm]
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Sortie de l'IP publique
output "ip_public" {
  value = aws_eip.ip.public_ip
}

# Créer une instance EC2 pour l'application
resource "aws_instance" "vm1" {
  ami           = "ami-023508951a94f0c71"  # Remplacez par l'AMI appropriée
  instance_type = "t4g.micro"  # Utilisez un type d'instance compatible

  subnet_id                   = aws_subnet.public_subnet1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.app_sg.id]

  tags = {
    Name = "app-vm1"
  }
}

# Créer une deuxième instance EC2 pour l'application
resource "aws_instance" "vm2" {
  ami           = "ami-023508951a94f0c71"  # Remplacez par l'AMI appropriée
  instance_type = "t4g.micro"  # Utilisez un type d'instance compatible

  subnet_id                   = aws_subnet.public_subnet2.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.app_sg.id]

  tags = {
    Name = "app-vm2"
  }
}

provider "aws" {
  region = var.REGION
}
resource "aws_key_pair" "terraproject" {
  key_name   = "terraform_project_key"
  public_key = file("terraproj.pub")
}
resource "aws_security_group" "terraformsg" {
  name        = "terraform_security_group"
  description = "Allow HTTP inbound traffic"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [aws_security_group.terraformlbsg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_instance" "webserver" {
  ami             = "ami-02d7fd1c2af6eead0"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.terraproject.key_name
  security_groups = [aws_security_group.terraformsg.name]
  user_data       = file("user_data.sh")

  tags = {
    Name = "Server for Terraform Project"
  }
  provisioner "file" {
    source      = "user_data.sh"
    destination = "/tmp/user_data.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "chmod +x /tmp/user_data.sh",
      "sudo /tmp/user_data.sh"
    ]
  }
  connection {
    user        = var.USER
    private_key = file("terraproj")
    host        = self.public_ip
  }
}
output "PublicIP" {
  value = aws_instance.webserver.public_ip
}
output "PrivateIP" {
  value = aws_instance.webserver.private_ip
}

resource "aws_lb_target_group_attachment" "TerraformAttach" {
  target_group_arn = aws_lb_target_group.TerraformTG.arn
  target_id        = aws_instance.webserver.id
}
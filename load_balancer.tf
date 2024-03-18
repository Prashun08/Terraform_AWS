resource "aws_lb" "TerraformLB" {
  name               = "TerraformLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraformlbsg.id]
  subnets = ["subnet-024d105bde5712a15",
    "subnet-02f5ff93077bfddaf",
    "subnet-04a31ac70bd8c9633",
    "subnet-09047d00e62d600e3",
    "subnet-0a578f328df5c6279",
  "subnet-09bce702927b628bf"]
}

resource "aws_security_group" "terraformlbsg" {
  name        = "terraform_security_group_load_balancer"
  description = "Allow HTTP inbound traffic"
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
}

resource "aws_lb_target_group" "TerraformTG" {
  name     = "TerraformTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0b89b965dc8100253"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "terraformlistener" {
  load_balancer_arn = aws_lb.TerraformLB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.TerraformTG.arn
    type             = "forward"
  }
}
# security.tf

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "load-balancer-security-group"

  }
}
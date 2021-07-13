# alb.tf

resource "aws_alb" "main" {
  name            = var.lb_name
  subnets         = var.subnets_list
  security_groups = [aws_security_group.lb.id]

  tags = {
    Name = var.lb_name
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }

}
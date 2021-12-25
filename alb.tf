resource "aws_lb_target_group" "task_tg" {
  name        = "${var.env}-task-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "task_listener" {
  load_balancer_arn = aws_lb.task_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_tg.arn
  }
}

resource "aws_lb" "task_alb" {
  name               = "${var.env}-task-alb"
  internal           = false
  security_groups    = [
    var.external_sg,
    var.internal_sg,
  ]
  subnets            = var.alb_subnets
}

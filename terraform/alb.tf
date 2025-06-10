resource "aws_lb" "demo_lb" {
  name = "demoapp-lb"
  internal = false
  load_balancer_type = "application"
  subnets = [for subnet in aws_subnet.public_subnets : subnet.id]
  security_groups = [ aws_security_group.main_sg.id ]
}


resource "aws_lb_target_group" "demo_lb_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main_vpc.id
  target_type = "ip"
}


resource "aws_lb_listener" "demo_lb_lt" {
  load_balancer_arn = aws_lb.demo_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.demo_lb_tg.arn
  }
}

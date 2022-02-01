
#---------------------------------------------------
# Create Application Load Balancer
#---------------------------------------------------

resource "aws_alb" "mylb" {
    name = "mylb"
    internal           = false
    load_balancer_type = "application"
    subnets = aws_subnet.pubsubnets.*.id   
    security_groups = [aws_security_group.alb.id]
      tags = {
        Name        = "${var.project}-mylb"    
        
     }
}

#---------------------------------------------------
# Create ALB- listener
#---------------------------------------------------

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.mylb.arn
  port              = var.app_port
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.mytarget.id
    }
  }
#---------------------------------------------------
# Create ALB- TARGET GROUP
#---------------------------------------------------

resource "aws_alb_target_group" "mytarget" {
  name        = "${var.project}-target"
  port        = var.app_target_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.newvpc.id
  target_type = "ip"

  tags = {
    Name = "${var.project}_${var.env}_tg"
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "15"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
    path                = var.health_check_path
  }
}
#---------------------------------------------------
# Create ALB- SEQURITY GROUP
#---------------------------------------------------
resource "aws_security_group" "alb" {
  name   = "${var.project}-sg_alb"
  vpc_id = aws_vpc.newvpc.id

  tags = {
    Name = "${var.project}_sg_alb"
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


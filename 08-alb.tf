# 8 - Create Application load balancer
# Create Application Load Balancer with 2 target groups:
# target group 1: name=ghost-ec2,port=2368,protocol="HTTP"
# target group 2: name=ghost-fargate,port=2368,protocol="HTTP"
# Create ALB listener: port=80,protocol="HTTP", avalability zone=a,b,c
# Edit ALB listener rule: action type = "forward",target_group_1_weight=50,target_group_2_weight=50

# Create ALB
resource "aws_lb" "ghost-alb" {
    name                        = "ghost-alb"
    internal                    = false
    load_balancer_type          = "application"
    security_groups             = [aws_security_group.alb.id]
    subnets                     = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
    enable_deletion_protection  = false
}

# Create ALB target group
resource "aws_lb_target_group" "ghost-alb-ec2" {
    name                        = "ghost-ec2"
    port                        = 2368
    protocol                    = "HTTP"
    target_type                 = "instance"
    vpc_id                      = aws_vpc.cloudx-vpc.id
    slow_start                = 300
    health_check {
      path                      = "/"
      enabled                   = true
      interval                  = 300
      port                      = 2368
      protocol                  = "HTTP"
      matcher                   = "200-499"
    }
}

# Create ALB target group
resource "aws_lb_target_group" "ghost-alb-fargate" {
    name                        = "ghost-fargate"
    port                        = 2368
    protocol                    = "HTTP"
    target_type                 = "ip"
    vpc_id                      = aws_vpc.cloudx-vpc.id
    slow_start                = 300
    health_check {
      path                      = "/"
      enabled                   = true
      interval                  = 300
      port                      = 2368
      protocol                  = "HTTP"
      matcher                   = "200-499"
    }
}

resource "aws_lb_listener" "ghost-alb-listener" {
  load_balancer_arn = aws_lb.ghost-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ghost-alb-ec2.arn
        weight           = 50
      }
      target_group {
        arn = aws_lb_target_group.ghost-alb-fargate.arn
        weight           = 50
      }
    }    
  }
}


# 10 - Create Auto-scaling group 
#   Create Auto-scaling group and assign it with Launch Template from #9:
#   name=ghost_ec2_pool
#   avalability zone=a,b,c
#   Attach ASG with {ghost-ec2} target group.

resource "aws_autoscaling_group" "ghost_ec2_pool" {
  name                        = "ghost_ec2_pool"
  min_size                    = 3
  max_size                    = 5
  desired_capacity            = 4
  target_group_arns           = [aws_lb_target_group.ghost-alb-ec2.arn]
  health_check_type           = "ELB"
  vpc_zone_identifier         = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id ]
  depends_on                  = [aws_launch_template.ghost, aws_iam_role.ghost_app]
  launch_template {
    id = aws_launch_template.ghost.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [target_group_arns, load_balancers]
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.ghost_ec2_pool.name
  lb_target_group_arn    = aws_lb_target_group.ghost-alb-ec2.arn
}

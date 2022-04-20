# #Create the following security groups:
#   name=ec2_pool, description="allows access for ec2 instances":
#     ingress rule_1: port=22, source={your_ip}, protocol=tcp
#     ingress rule_2: port=2049, source={vpc_cidr}, protocol=tcp
#     ingress rule_3: port=2368, source_security_group={alb}, protocol=tcp
#     egress rule: allows any destination
#   name=fargate_pool, description="allows access for fargate instances":
#     ingress rule_1: port=2049, source={vpc_cidr}, protocol=tcp
#     ingress rule_2: port=2368, source_security_group={alb}, protocol=tcp
#     egress rule: allows any destination
#   name=mysql, description="defines access to ghost db":
#     ingress rule_1: port=3306, source_security_group={ec2_pool}, protocol=tcp
#     ingress rule_2: port=3306, source_security_group={fargate_pool}, protocol=tcp
#  name=efs, description="defines access to efs mount points":
#     ingress rule_1: port=2049, source_security_group={ec2_pool}, protocol=tcp
#     ingress rule_2: port=2049, source_security_group={fargate_pool}, protocol=tcp
#     egress rule: allows any destination to {vpc_cidr}
#   name=alb, description="defines access to alb":
#     ingress rule_1: port=80, source={your_ip}, protocol=tcp
#     egress rule 1: port=any, source_security_group={ec2_pool}, protocol=any
#     egress rule 2: port=any, source_security_group={fargate_pool}, protocol=any
#  name=vpc_endpoint, description="defines access to vpc endpoints":
#     ingress rule_1: port=443, source={vpc_cidr}, protocol=tcp



### Security Groups
resource "aws_security_group" "ec2_pool" {
  name        = "ec2_pool"
  description = "allows access for ec2 instances"
  vpc_id      = aws_vpc.cloudx-vpc.id
}

resource "aws_security_group" "fargate_pool" {
  name        = "fargate_pool"
  description = "allows access for fargate instances"
  vpc_id      = aws_vpc.cloudx-vpc.id
}


resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "defines access to ghost db"
  vpc_id      = aws_vpc.cloudx-vpc.id
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "defines access to efs mount points"
  vpc_id      = aws_vpc.cloudx-vpc.id

}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "defines access to alb"
  vpc_id      = aws_vpc.cloudx-vpc.id
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc_endpoint"
  description = "defines access to vpc endpoints"
  vpc_id      = aws_vpc.cloudx-vpc.id
}

## Security Group Rules

resource "aws_security_group_rule" "ec2_pool-1" {
    type                               = "ingress"
    from_port                          = 22
    to_port                            = 22
    protocol                           = "tcp"
    cidr_blocks                        = [format("%s/%s",data.external.mypubip.result["internet_ip"],32)]
    security_group_id                  = aws_security_group.ec2_pool.id

}

resource "aws_security_group_rule" "ec2_pool-2" {
    type                               = "ingress"
    from_port                          = 2049
    to_port                            = 2049
    protocol                           = "tcp"
    cidr_blocks                        = [aws_vpc.cloudx-vpc.cidr_block]
    security_group_id                  = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "ec2_pool-3" {
    type                               = "ingress"
    from_port                          = 2368
    to_port                            = 2368
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.ec2_pool.id
    source_security_group_id           = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_pool-4" {
    type                               = "egress"
    from_port                          = 0
    to_port                            = 0
    protocol                           = "-1"
    cidr_blocks                        = ["0.0.0.0/0"]
    security_group_id                  = aws_security_group.ec2_pool.id

}

#

resource "aws_security_group_rule" "fargate_pool-1" {
    type                               = "ingress"
    from_port                          = 2049
    to_port                            = 2049
    protocol                           = "tcp"
    cidr_blocks                        = [aws_vpc.cloudx-vpc.cidr_block]
    security_group_id                  = aws_security_group.fargate_pool.id

}

resource "aws_security_group_rule" "fargate_pool-2" {
    type                               = "ingress"
    from_port                          = 2368
    to_port                            = 2368
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.fargate_pool.id
    source_security_group_id           = aws_security_group.alb.id
}

resource "aws_security_group_rule" "fargate_pool-3" {
    type                               = "egress"
    from_port                          = 0
    to_port                            = 0
    protocol                           = "-1"
    cidr_blocks                        = ["0.0.0.0/0"]    
    security_group_id                  = aws_security_group.fargate_pool.id

}
#


resource "aws_security_group_rule" "mysql-1" {
    type                               = "ingress"
    from_port                          = 3306
    to_port                            = 3306
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.mysql.id
    source_security_group_id           = aws_security_group.ec2_pool.id

}

resource "aws_security_group_rule" "mysql-2" {
    type                               = "ingress"
    from_port                          = 3306
    to_port                            = 3306
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.mysql.id
    source_security_group_id           = aws_security_group.fargate_pool.id
}

#



resource "aws_security_group_rule" "efs-1" {
    type                               = "ingress"
    from_port                          = 2049
    to_port                            = 2049
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.efs.id
    source_security_group_id           = aws_security_group.efs.id

}

resource "aws_security_group_rule" "efs-2" {
    type                               = "ingress"
    from_port                          = 2049
    to_port                            = 2049
    protocol                           = "tcp"
    security_group_id                  = aws_security_group.efs.id
    source_security_group_id           = aws_security_group.fargate_pool.id
}

resource "aws_security_group_rule" "efs-3" {
    type                               = "egress"
    from_port                          = 0
    to_port                            = 0
    protocol                           = "-1"
    cidr_blocks                        = [aws_vpc.cloudx-vpc.cidr_block]
    security_group_id                  = aws_security_group.efs.id

}
#


resource "aws_security_group_rule" "alb-1" {
    type                               = "ingress"
    from_port                          = 80
    to_port                            = 80
    protocol                           = "tcp"
    cidr_blocks                        = [format("%s/%s",data.external.mypubip.result["internet_ip"],32)]
    security_group_id                  = aws_security_group.alb.id

}

resource "aws_security_group_rule" "alb-2" {
    type                               = "egress"
    from_port                          = 0
    to_port                            = 0
    protocol                           = "-1"
    security_group_id                  = aws_security_group.alb.id
    source_security_group_id           = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "alb-3" {
    type                               = "egress"
    from_port                          = 0
    to_port                            = 0
    protocol                           = "-1"
    security_group_id                  = aws_security_group.alb.id
    source_security_group_id           = aws_security_group.fargate_pool.id

}

#


resource "aws_security_group_rule" "vpc_endpoint-1" {
    type                               = "ingress"
    from_port                          = 443
    to_port                            = 443
    protocol                           = "tcp"
    cidr_blocks                        = [aws_vpc.cloudx-vpc.cidr_block]
    security_group_id                  = aws_security_group.vpc_endpoint.id

}



## IP Checking

data "external" "mypubip" {
  program = ["/bin/bash" , "${path.module}/scripts/mypubip.sh"]
}
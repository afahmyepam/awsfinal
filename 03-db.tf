
# 3 - Create Database
#   Create DB related resources:
#     Subnet_group:
#       name=ghost, subnet_ids={private_db_a,private_db_b,private_db_c}, description='ghost database subnet group'
#     MySQL Database:
#     name=ghost, instance_type=db.t2.micro, engine_version=8.0, storage=gp2, 
#     allocated_space=20Gb, security_groups={mysql}, subnet_groups={ghost}
resource "aws_db_subnet_group" "ghost" {
  name       = "ghost"
  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id,
    aws_subnet.private_db_c.id
    ]

  tags = {
    Name = "ghost"
    description = "ghost database subnet group"
  }
}

resource "aws_db_instance" "ghost" {
  instance_class             = "db.t2.micro"
  identifier                 = "ghost"
  allocated_storage          = 20
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "8.0"
  db_name                    = "ghost"
  username                   = "ghost"
  password                   = random_password.randompass.result
  db_subnet_group_name       = aws_db_subnet_group.ghost.name
  delete_automated_backups   = true
  parameter_group_name       = "default.mysql8.0"
  deletion_protection        = false
  skip_final_snapshot        = true
  backup_retention_period    = 0
  apply_immediately          = true
  vpc_security_group_ids     = [aws_security_group.mysql.id]
  multi_az                   = true
  
}


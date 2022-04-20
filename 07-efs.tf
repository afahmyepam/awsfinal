# 7 - Create EFS 
#   Create EFS file system resource(name=ghost_content)
#   Create EFS mount targets for each AZ and assign them with {efs} security group



resource "aws_efs_file_system" "ghost_content" {
  creation_token = "ghost_content"

  tags = {
    Name = "ghost_content"
  }
}

resource "aws_efs_mount_target" "ghost_content_a" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.public_a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "ghost_content_b" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.public_b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "ghost_content_c" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.public_c.id
  security_groups = [aws_security_group.efs.id]
}

# access point
resource "aws_efs_access_point" "ghost_efs_access_point" {
  file_system_id = aws_efs_file_system.ghost_content.id
}
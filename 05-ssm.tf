# 5 - Store DB password in a safe way
#   Generate DB password and store in in SSM Parameter store as secure string(name=/ghost/dbpassw).

resource "random_password" "randompass"{
  length           = 16
  special          = true
  override_special = "_!%^"
}


resource "aws_ssm_parameter" "secret" {
  name        = "/ghost/dbpassw"
  description = "ghost db password location"
  type        = "SecureString"
  value       = random_password.randompass.result
}

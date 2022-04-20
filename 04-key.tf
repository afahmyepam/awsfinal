# 4 - Create SSH Key pair 
#   Create custom ssh key-pair to access your ec2 instances
#   Upload it to AWS with name=ghost-ec2-pool


resource "aws_key_pair" "ghost-ec2-pool" {
  key_name   = "ghost-ec2-pool"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDplhxxzF+WReY5C0nAmxe23Y1kSM/DNalCBswqQCxnAcmSqHRVNhQ0G4L4zqCIGdOp1JRxZXgHfTiBJ2QrTA6cbPA2CiU4M9DuaKDZnF3kp6VUJGg++qHi8vLTFJZV8H8ETbgIMhJBErVQ6Fca8T2dcp73p5ZAe1TOPjS7KUJVYm69zti/Oa+w8mkCOhtIkYnrpImqxHx1K12WCXx0bMQ2kW26uRR52I6vAztlwRusuzf7pUDmZ8ZAz6NOcs/QPJ0MMKS79wPWQ+3L0feBI0swcqFS8l/UUjENOeCNxcvt21egKOD0QeeR3PJZiGBNS9nCZ2bR6fadYF894SIM1DBf"
}

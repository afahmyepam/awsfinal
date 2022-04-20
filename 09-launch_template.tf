# 9 - Create Launch Template 
# In this task you have to author launch tempalate to run Ghost application with UserData script on instance start up. Use Amazon Linux 2 as the base image.
# Start up script should do the following:
#
# install pre-requirements
# create /var/lib/ghost/content directory and mount {ghost_content} EFS volume to the instance
# download and run Ghost application
# Read DB password from the secret store
#
#
#   Script example(click to expand):
# #!/bin/bash -xe
# export HOME="/root"
# SSM_DB_PASSWORD="/gh/db/pass"
# GHOST_PACKAGE="ghost-4.12.1.tgz"
# DB_URL=${db_url_tpl}
# DB_USER="gh_user"
# DB_NAME="gh_db"
#
# REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
# DB_PASSWORD=$(aws ssm get-parameter --name $SSM_DB_PASSWORD --query Parameter.Value --with-decryption --region $REGION --output text)
# EFS_ID=$(aws efs describe-file-systems --query 'FileSystems[?Name==`gh_data`].FileSystemId' --region $REGION --output text)
#
# ### Install pre-reqs
# curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
# sudo python3 /tmp/get-pip.py
# sudo /usr/local/bin/pip install botocore
# curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
# sudo yum install -y nodejs
# sudo npm install pm2 -g
#
# ### EFS mount
# mkdir -p /var/lib/ghost/content
# yum -y install amazon-efs-utils
# mount -t efs -o tls $EFS_ID:/ /var/lib/ghost/content
#
# ### Configure and start ghost app
# mkdir ghost
# wget https://registry.npmjs.org/ghost/-/$GHOST_PACKAGE
# tar -xzvf $GHOST_PACKAGE -C ghost --strip-components=1
# rm $GHOST_PACKAGE && cd ghost
#
# cat << EOF >> config.production.json
# {
#     "database": {
#             "client": "mysql",
#             "connection": {
#                     "host": "$DB_URL",
#                     "port": 3306,
#                     "user": "$DB_USER",
#                     "password": "$DB_PASSWORD",
#                     "database": "$DB_NAME"
#             }
#     },
#     "server": {
#             "host": "0.0.0.0",
#             "port": "2368"
#     },
#     "paths": {
#         "contentPath": "/var/lib/ghost/content"
#     }
# }
# EOF
#
# rsync -axvr --ignore-existing /ghost/content/ /var/lib/ghost/content || true
# chmod 755 -R /var/lib/ghost
#
# npm install
#
# NODE_ENV=production pm2 start /ghost/index.js --name "ghost" -i max
#
#
# You can refer to the application documentation
# Сreate Launch Templpate:
#
# (name=ghost,instance_type=t2.micro, security_group={ec2_pool.id}, key_name={ghost-ec2-pool}, userdata={your_startup_script}, iam_role_profile={ghost_app})
#
# To check script you can run single EC2 instance using Launch Template. Don't forget to remove it after testing.
# Hint: you can use cloud-init log to examine userData scipt output(/var/log/cloud-init-output.log)
# Hint: you can use pm2 logs|staus commands to troublshout ghost application.

resource "aws_iam_instance_profile" "ghost-profile" {
  name = "ghost-profile"
  role = aws_iam_role.ghost_app.name
}


resource "aws_launch_template" "ghost" {
  name                   = "ghost"
  instance_type          = "t2.micro"
  image_id               = "ami-01d9d7f15bbea00b7"
  vpc_security_group_ids = [aws_security_group.ec2_pool.id]
  key_name               = "ghost-ec2-pool"
  user_data              = filebase64("${path.module}/scripts/startup.sh")
  depends_on = [aws_iam_instance_profile.ghost-profile]
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost-profile.name
  }
}


AWS Assoc. final task
Requires docker / awscli / terraform



to create:
terraform init
terraform apply --auto-approve

to destroy:
terraform destroy --auto-approve


Notes:
Using eu-central-1 location, AMI is used in this region
DB URL has to be inserted after creation into ecs.tf and startup.sh script
AMI will need to be changed in case updated or region changed


Future Plans:
to automate some tasks in script ~ docker image creation
to use more variables


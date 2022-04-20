#!/usr/bin/env bash
set -e

REGION="eu-central-1"
LB="arn:aws:elasticloadbalancing:eu-central-1:301684269231:loadbalancer/app/ghost-alb/16a6cf14e918b25b"
for i in  $(aws elbv2 describe-target-groups --load-balancer-arn $LB  --region $REGION | \
 jq -r '.TargetGroups[].TargetGroupArn'); do aws elbv2 describe-target-health --target-group-arn $i --region $REGION; done
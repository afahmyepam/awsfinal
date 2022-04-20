#!/bin/bash
# script from https://www.itwonderlab.com/en/use-your-public-internet-ip-address-terraform/
set -e
INTERNETIP="$(curl https://checkip.amazonaws.com)"
echo $(jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}')
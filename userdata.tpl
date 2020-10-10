#!/bin/bash
set -euo pipefail

sudo yum install -y docker
sudo easy_install pip
sudo pip install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
#sudo yum install -y aws-cfn-bootstrap
#docker run --name some-wordpress -e WORDPRESS_DB_HOST=10.1.2.3:3306 -e WORDPRESS_DB_USER= -e WORDPRESS_DB_PASSWORD= -d wordpress



# echo "Checking that agent is running"
# until $(curl --output /dev/null --silent --head --fail http://localhost:51678/v1/metadata); do
#   printf '.'
#   sleep 1
# done
# exit_code=$?
# printf "\nDone\n"

# Can't signal back if the stack is in UPDATE_COMPLETE state, so ignore failures to do so.
# CFN will roll back if it expects the signal but doesn't get it anyway.
echo "Reporting $exit_code exit code to Cloudformation"
# /opt/aws/bin/cfn-signal \
#   --exit-code "$exit_code" \
#   --stack "$CFN_STACK" \
#   --resource ASG \
#   --region "$REGION" || true

/bin/cfn-signal -e 0 --stack ${cfn_stack_name} --resource ASG --region us-east-1
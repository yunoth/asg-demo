#!/bin/bash
#set -euo pipefail

sudo yum install -y docker
sudo easy_install pip
sudo pip install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
#docker run --name some-wordpress -e WORDPRESS_DB_HOST=10.1.2.3:3306 -e WORDPRESS_DB_USER=${db_username} -e WORDPRESS_DB_PASSWORD=${db_password} -d wordpress

exit_code=$?

# Can't signal back if the stack is in UPDATE_COMPLETE state, so ignore failures to do so.
# CFN will roll back if it expects the signal but doesn't get it anyway.
echo "Reporting $exit_code exit code to Cloudformation"
/bin/cfn-signal -e $exit_code --stack ${cfn_stack_name} --resource ASG --region us-east-1
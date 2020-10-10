#!/bin/bash

sudo yum install docker
docker run --name some-wordpress -e WORDPRESS_DB_HOST=10.1.2.3:3306 -e WORDPRESS_DB_USER= -e WORDPRESS_DB_PASSWORD= -d wordpress
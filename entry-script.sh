#!/bin/bash

PROJECT_NAME="forkify"
REPO_URL="https://github.com/ngxminhphuc/forkify.git"
PROJECT_DIR="/repo/$PROJECT_NAME"
NGINX_CONF="/etc/nginx/conf.d/$PROJECT_NAME.conf"
BUILD_DIR="$PROJECT_DIR/dist"

yum update -y
yum install -y git nginx nodejs


git clone $REPO_URL $PROJECT_DIR
cd $PROJECT_DIR

npm install && npm run build
systemctl start nginx

echo "server {
  listen       80;
  location / {
    root   $BUILD_DIR;
    index  index.html;
    try_files \$uri \$uri/ /index.html;
  }
}" | sudo tee $NGINX_CONF

chown -R nginx:nginx $PROJECT_DIR
chmod -R 755 $PROJECT_DIR
nginx -s reload

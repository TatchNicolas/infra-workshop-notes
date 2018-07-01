#! /bin/bash

sudo yum install -y curl policycoreutils-python

sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo EXTERNAL_URL="http://localhost" yum install -y gitlab-ce

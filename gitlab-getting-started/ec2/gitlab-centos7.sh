#! /bin/bash

sudo yum install -y curl policycoreutils-python

sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

export EXTERNAL_URL=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sudo yum install -y gitlab-ee

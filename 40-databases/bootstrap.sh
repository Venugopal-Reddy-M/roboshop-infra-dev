#!/bin/bash

component=$1
#environment=$2
dnf install ansible -y

cd /home/ec2-user
git clone https://github.com/Venugopal-Reddy-M/ansible-roboshop-roles-tf.git

cd ansible-roboshop-roles-tf
git pull

ansible-playbook -e component=$component roboshop.yaml
# ansible-playbook -e component=$component -e env=$environment roboshop.yaml
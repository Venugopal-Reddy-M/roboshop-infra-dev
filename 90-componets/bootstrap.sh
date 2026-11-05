# #!/bin/bash

# component=$1
# environment=$2
# app_version=$3
# dnf install ansible -y

# cd /home/ec2-user
# git clone https://github.com/Venugopal-Reddy-M/ansible-roboshop-roles-tf.git

# cd ansible-roboshop-roles-tf
# git pull
# ansible-playbook -e component=$component -e env=$environment -e app_version=$app_version roboshop.yaml

#!/bin/bash

component=$1 #catalogue
environment=$2 #dev
app_version=$3
dnf install ansible -y
mkdir -p /var/log/roboshop/
chown -R ec2-user:ec2-user /var/log/roboshop
chmod -R 755 /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd /home/ec2-user
git clone https://github.com/Venugopal-Reddy-M/ansible-roboshop-roles-tf.git
cd ansible-roboshop-roles-tf
git pull
ansible-playbook -e component=$component -e env=$environment -e app_version=$app_version roboshop.yaml


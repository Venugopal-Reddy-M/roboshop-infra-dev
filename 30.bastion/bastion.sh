growpart /dev/nvme0n1 4

lvextend -r -L + 30G /dev/mapper/RootVG-homeVol

xfs-growfs /home

# install terraform
yum install yum-utils -y
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp
yum -y install terraform        

#! /bin/bash

# Replace with yours
USER=tatch
GITHUB_ID=tatchnicolas

# Create group and user
groupadd $USER
useradd -g $USER -d /home/$USER -s /bin/bash -m $USER
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set up SSH
mkdir /home/$USER/.ssh
chown $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
curl https://github.com/$GITHUB_ID.keys > /home/$USER/.ssh/authorized_keys 2>/dev/null
echo AllowUsers $USER vagrant >> /etc/ssh/sshd_config
systemctl restart sshd

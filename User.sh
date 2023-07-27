#!/bin/bash
#User

#MONGODB_SERVER_IP_ADDRESS="18.207.225.191"
#REDIS_SERVER_IP="44.204.188.12"
echo "Before we run script i need IP address of MongoDb server so ...   ... "
read -p "Enter MongoDB IP Address := " MongoDB_IP
read -p "Enter Frontend IP Address := " Frontend_IP
read -p "Enter Redis IP Address := " Redis_IP
read -p "Enter User IP Address := " User_IP

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y

useradd roboshop
mkdir /app
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
cd /app
unzip /tmp/user.zip
cd /app
npm install

echo "[Unit]
Description = User Service
[Service]
User=roboshop
Environment=MONGO=true
Environment=REDIS_HOST=$Redis_IP
Environment=MONGO_URL="mongodb://$MongoDB_IP:27017/users"
ExecStart=/bin/node /app/server.js
SyslogIdentifier=user

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/user.service


#sed -i "s/MongoDB_IP/$MongoDB_IP/" /etc/systemd/system/user.service

#sed -i "s/Redis_IP/$Redis_IP/" /etc/systemd/system/user.service



systemctl daemon-reload
systemctl enable user
systemctl start user

echo "[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/mongo.repo

yum install mongodb-org-shell -y

mongo --host $MongoDB_IP </app/schema/user.js

# do not forget to change user ip in frontend
echo "here is your ip $User_IP" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -c 'sudo sed -i "/user/s/localhost/$User_IP/" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx; uname -a; echo "I am a $HOSTNAME"; exit'"

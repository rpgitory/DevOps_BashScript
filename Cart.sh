#!/bin/bash
#Cart

#REDIS_SERVER_IP="44.204.188.12"
#CATALOGUE_SERVER_IP="54.90.145.82"

read -p "Enter Frontend IP Address := " Frontend_IP
read -p "Enter Redis IP Address := " Redis_IP
read -p "Enter Catalogue IP Address := " Catalogue_IP
read -p "Enter Cart IP Address := " Cart_IP

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y


useradd roboshop
mkdir /app
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip
cd /app
unzip /tmp/cart.zip

cd /app
npm install

echo "[Unit]
Description = Cart Service
[Service]
User=roboshop
Environment=REDIS_HOST=$Redis_IP
Environment=CATALOGUE_HOST=$Catalogue_IP
Environment=CATALOGUE_PORT=8080
ExecStart=/bin/node /app/server.js
SyslogIdentifier=cart

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/cart.service

#sed -i "s/REDIS_SERVER_IP/$REDIS_SERVER_IP/" /etc/systemd/system/cart.service
#sed -i "s/CATALOGUE_SERVER_IP/$CATALOGUE_SERVER_IP/" /etc/systemd/system/cart.service

systemctl daemon-reload

systemctl enable cart
systemctl start cart

# do not forget to change user ip in frontend

echo "here is your ip $Cart_IP" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -c 'sudo sed -i "/cart/s/localhost/$Cart_IP/" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx; uname -a; echo "I am a $HOSTNAME"; exit'"

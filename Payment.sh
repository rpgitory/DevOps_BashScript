#!/bin/bash 
#Payment

#CART_SERVER_IPADDRESS="54.146.196.52"
#USER_SERVER_IPADDRESS="54.198.199.151"
#RABBITMQ_SERVER_IPADDRESS="54.172.219.35"

read -p "Enter Frontend IP Address := " Frontend_IP
read -p "Enter Cart IP Address := " Cart_IP
read -p "Enter RabbitMQ IP Address := " RabbitMQ_IP
read -p "Enter User IP Address := " User_IP
read -p "Enter Payment IP Address := " Payment_IP

yum install python36 gcc python3-devel -y

useradd roboshop
mkdir /app
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip
cd /app
unzip /tmp/payment.zip

cd /app
pip3.6 install -r requirements.txt


echo "[Unit]
Description=Payment Service

[Service]
User=root
WorkingDirectory=/app
Environment=CART_HOST=$Cart_IP
Environment=CART_PORT=8080
Environment=USER_HOST=$User_IP
Environment=USER_PORT=8080
Environment=AMQP_HOST=$RabbitMQ_IP
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123

ExecStart=/usr/local/bin/uwsgi --ini payment.ini
ExecStop=/bin/kill -9 \$MAINPID
SyslogIdentifier=payment

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/payment.service

#sed -i "s/CART_SERVER_IPADDRESS/$CART_SERVER_IPADDRESS/" /etc/systemd/system/payment.service
#sed -i "s/USER_SERVER_IPADDRESS/$USER_SERVER_IPADDRESS/" /etc/systemd/system/payment.service
#sed -i "s/RABBITMQ_SERVER_IPADDRESS/$RABBITMQ_SERVER_IPADDRESS/" /etc/systemd/system/payment.service


systemctl daemon-reload

systemctl enable payment
systemctl start payment

#Do not forget change Shipping ip in frontend

echo "here is your ip $Payment_IP" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -c 'sudo sed -i "/payment/s/localhost/$Payment_IP/" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx; uname -a; echo "I am a $HOSTNAME"; exit'"

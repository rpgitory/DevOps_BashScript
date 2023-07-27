#!/bin/bash
#Dispatched 


#RABBITMQ_IP="54.172.219.35"
read -p "Enter RabbitMQ IP Address := " RabbitMQ_IP

yum install golang -y

useradd roboshop
mkdir /app
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip
cd /app
unzip /tmp/dispatch.zip
cd /app
go mod init dispatch
go get
go build

echo "[Unit]
Description = Dispatch Service
[Service]
User=roboshop
Environment=AMQP_HOST=$RabbitMQ_IP
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123
ExecStart=/app/dispatch
SyslogIdentifier=dispatch

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/dispatch.service

#sed -i "s/RABBITMQ_IP/$RABBITMQ_IP/" /etc/systemd/system/dispatch.service


systemctl daemon-reload
systemctl enable dispatch
systemctl start dispatch

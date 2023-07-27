#!/bin/bash
#Shipping 


#CART_SERVER_IPADDRESS="54.146.196.52"
#MYSQL_SERVER_IPADDRESS="3.94.53.247"

read -p "Enter Frontend IP Address := " Frontend_IP
read -p "Enter Cart IP Address := " Cart_IP
read -p "Enter MySQL IP Address := " MySQL_IP
read -p "Enter Shipping IP Address := " Shipping_IP

yum install maven -y

useradd roboshop
mkdir /app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip
cd /app

unzip /tmp/shipping.zip

cd /app
mvn clean package
mv target/shipping-1.0.jar shipping.jar

echo "[Unit]
Description=Shipping Service

[Service]
User=roboshop
Environment=CART_ENDPOINT=$Cart_IP:8080
Environment=DB_HOST=$MySQL_IP
ExecStart=/bin/java -jar /app/shipping.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/shipping.service


#sed -i "s/MYSQL_SERVER_IPADDRESS/$MYSQL_SERVER_IPADDRESS/" /etc/systemd/system/shipping.service
#sed -i "s/CART_SERVER_IPADDRESS/$CART_SERVER_IPADDRESS/" /etc/systemd/system/shipping.service



systemctl daemon-reload
systemctl enable shipping
systemctl start shipping

yum install mysql -y

mysql -h $MySQL_IP -uroot -pRoboShop@1 < /app/schema/shipping.sql

systemctl restart shipping
	
#Do not forget change Shipping ip in frontend

echo "here is your ip $Shipping_IP" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -c 'sudo sed -i "/shipping/s/localhost/$Shipping_IP/" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx; uname -a; echo "I am a $HOSTNAME"; exit'"


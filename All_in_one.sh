#!/bin/bash
#Frontend
yum install sshpass
Frontend_IP=35.172.183.113
MongoDB_IP=54.226.232.254
Catalogue_IP=54.174.13.225
sshpass -p 'DevOps321' ssh centos@$Frontend_IP

yum install nginx -y

systemctl enable nginx
systemctl start nginx

rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip


echo "proxy_http_version 1.1;
location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files $uri /images/placeholder.jpg;
}
location /api/catalogue/ { proxy_pass http://localhost:8080/; }
location /api/user/ { proxy_pass http://localhost:8080/; }
location /api/cart/ { proxy_pass http://localhost:8080/; }
location /api/shipping/ { proxy_pass http://localhost:8080/; }
location /api/payment/ { proxy_pass http://localhost:8080/; }

location /health {
  stub_status on;
  access_log off;
}">/etc/nginx/default.d/roboshop.conf

systemctl restart nginx
#----------------------------------------------------------------------------------------------
sshpass -p 'DevOps321' ssh centos@$MongoDb_IP 'bash -s' << 'ENDSSH'

#!/bin/bash
#MongoDB


echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/mongo.repo

yum install mongodb-org -y
systemctl enable mongod
systemctl start mongod

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

systemctl restart mongod

exit
ENDSSH
#----------------------------------------------------------------------------------------------

sshpass -p 'DevOps321' ssh centos@$Catalogue_IP 'bash -s' << 'ENDSSH'

#!/bin/bash
#Catalogue


curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y

useradd roboshop
mkdir /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
cd /app
unzip /tmp/catalogue.zip

cd /app
npm install

echo '[Unit]
Description = Catalogue Service

[Service]
User=roboshop
Environment=MONGO=true
Environment=MONGO_URL="mongodb://MongoDB_IP:27017/catalogue"
ExecStart=/bin/node /app/server.js
SyslogIdentifier=catalogue

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/catalogue.service

sed -i "s/MongoDB_IP/$MongoDB_IP/" /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue

echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/mongo.repo

yum install mongodb-org-shell -y

mongo --host $MongoDB_IP </app/schema/catalogue.js

#do not forget to change Catalogue IP in Frontend file



REMOTE_FILE="/etc/nginx/default.d/roboshop.conf"


#sshpass -p "DevOps321" ssh "centos@$Fronend_IP" "sed -i '/catalogue s/localhost/$Catalogue_IP/' $REMOTE_FILE"

exit
ENDSSH
#----------------------------------------------------------------------------------------------



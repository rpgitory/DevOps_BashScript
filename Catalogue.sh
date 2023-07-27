#!/bin/bash
#Catalogue


#MONGODB_SERVER_IPADDRESS="18.207.225.191"
#MongoDB_IP
echo "Before we run script i need IP address of MongoDb server so ...   ... "
read -p "Enter MongoDB IP Address := " MongoDB_IP
read -p "Enter Frontend IP Address := " Frontend_IP
read -p "Enter Catalogue IP Address := " Catalogue_IP
#export Catalogue_IP
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y

useradd roboshop
mkdir /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
cd /app
unzip /tmp/catalogue.zip

cd /app
npm install

echo "[Unit]
Description = Catalogue Service

[Service]
User=roboshop
Environment=MONGO=true
Environment=MONGO_URL='mongodb://$MongoDB_IP:27017/catalogue'
ExecStart=/bin/node /app/server.js
SyslogIdentifier=catalogue

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/catalogue.service

#sed -i "s/MongoDB_IP/$MongoDB_IP/" /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue

echo "[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/mongo.repo

#cat << EOF > /etc/yum.repos.d/mongo.repo
#[mongodb-org-4.2]
#name=MongoDB Repository
#baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
#gpgcheck=0
#enabled=1
#EOF


yum install mongodb-org-shell -y

mongo --host $MongoDB_IP </app/schema/catalogue.js
#Catalogue_IP=12.365.124.25
#yum install sshpass

#read -p "Enter Catalogue IP Address := " Catalogue_IP

echo "here is your ip $Catalogue_IP" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -c 'sudo sed -i "/catalogue/s/localhost/$Catalogue_IP/" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx; uname -a; echo "I am a $HOSTNAME"; exit'"

#echo "sudo sed -i \"/catalogue/s/localhost/$Catalogue_IP/\" /etc/nginx/default.d/roboshop.conf; sudo systemctl restart nginx" | sshpass -p 'DevOps321' ssh centos@$Frontend_IP "xargs -I {} bash -s" << 'ENDSSH'
#uname a
#echo $USER
#ENDSSH


#read -p "Enter Catalogue IP Address := " Catalogue_IP| xarg sshpass -p "DevOps321" ssh -T centos@$Frontend_IP 'bash -s'<< 'ENDSSH'
#Remote_File="/etc/nginx/default.d/roboshop.conf"
#how to access Catalogue_IP variable in ssh login
#sudo sed -i "/catalogue/s/localhost/$Catalogue_IP/" /etc/nginx/default.d/roboshop.conf
#exit
#ENDSSH
#do not forget to change Catalogue IP in Frontend file

# Read user input on the client side
#read -p "Enter Catalogue IP Address := " Catalogue_IP # just for practice and it was workded but idk how

# Use sshpass and ssh to pass the value to the remote server
#echo "here is your ip $Catalogue_IP" | sshpass -p 'DevOps321' ssh centos@3.90.189.91 "xargs -I {} bash -c 'sudo sed -i "/catalogue/s/localhost/$Catalogue_IP/" /etc/nginx/default.d/roboshop.conf'" # just for practice and it was workded but idk how


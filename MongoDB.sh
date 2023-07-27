#!/bin/bash
#MongoDB


echo "[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/mongo.repo

yum install mongodb-org -y
systemctl enable mongod
systemctl start mongod

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

systemctl restart mongod
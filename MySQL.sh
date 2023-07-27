#!/bash/bin
#MySQL


yum module disable mysql -y

echo "[mysql]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/mysql.repo

yum install mysql-community-server -y

systemctl enable mysqld
systemctl start mysqld

mysql_secure_installation --set-root-pass RoboShop@1

mysql -uroot -pRoboShop@1


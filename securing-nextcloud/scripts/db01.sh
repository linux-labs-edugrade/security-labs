yum install -y mariadb-server

systemctl start mariadb

mysql -u root -e "create database nextcloud;"
mysql -u root -e "create user 'nextcloud'@'%' identified by 'nextcloud';"
mysql -u root -e "grant all privileges on nextcloud.* to 'nextcloud'@'%';"

mysql -u root nextcloud < /home/vagrant/nextcloud.sql

rm -rf /home/nextcloud/nextcloud.sql

mysql -u root -e "alter user 'root'@'localhost' identified by 'security';"


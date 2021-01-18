yum install -y epel-release
yum makecache

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd


echo "hk01:x:1500:1500::/home/hk01:/bin/bash" >> /etc/passwd
echo "hk01:x:1500:" >> /etc/group
echo 'hk01:$6$NNXKGBvzkaPAUKPc$QyF5JJ28l5wHx2mUSGNeWYW5iTo7vuzS3NeiCZL0HuTZ8Y93fvKqhtxkuaCKeRKWOfcb.0uLnO.nkovMEEDPH0::0:99999:7:::' >> /etc/shadow
mkdir /home/hk01
chown -R hk01:hk01 /home/hk01
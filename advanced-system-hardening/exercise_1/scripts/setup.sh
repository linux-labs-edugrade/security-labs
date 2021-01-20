yum install -y epel-release
yum makecache

yum install -y nginx

cat << EOF >> /etc/nginx/conf.d/simple-ssl.conf

server {
   listen       443 ssl;
   server_name localhost;
   ssl                 on;
   ssl_certificate     /path/to/key.pem;
   ssl_certificate_key /path/to/cert.pem;
   ssl_protocols       "<INSERT CIPHERS HERE>";
   ssl_prefer_server_ciphers   on;
   ssl_ciphers "< INSERT CIPHERS >";
   ssl_dhparam     /path/to/dh.pem;

   root         /usr/share/nginx/html;

   location / {}
}

EOF
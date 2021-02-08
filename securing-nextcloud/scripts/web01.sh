yum install -y nginx php-fpm unzip wget php-dom php-gd php-json php-mbstring php-posix php-simplexml php-xmlreader php-xmlwriter php-zip php php-fileinfo php-bz2 php-pdo php-mysqlnd

sed -i 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php.ini
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf

cat << EOF > /etc/nginx/nginx.conf
user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
}
EOF

cat << EOF > /etc/nginx/conf.d/nextcloud.conf
server {
    listen 80;
    server_name localhost;

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    add_header Referrer-Policy                      "no-referrer"   always;
    add_header X-Content-Type-Options               "nosniff"       always;
    add_header X-Download-Options                   "noopen"        always;
    add_header X-Frame-Options                      "SAMEORIGIN"    always;
    add_header X-Permitted-Cross-Domain-Policies    "none"          always;
    add_header X-Robots-Tag                         "none"          always;
    add_header X-XSS-Protection                     "1; mode=block" always;

    fastcgi_hide_header X-Powered-By;

    root /var/www/nextcloud;

    index index.php index.html /index.php\$request_uri;

    location = / {
        if ( \$http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/\$is_args\$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ^~ /.well-known {
        # The following 6 rules are borrowed from `.htaccess`

        rewrite ^/\.well-known/host-meta\.json  /public.php?service=host-meta-json  last;
        rewrite ^/\.well-known/host-meta        /public.php?service=host-meta       last;
        rewrite ^/\.well-known/webfinger        /public.php?service=webfinger       last;
        rewrite ^/\.well-known/nodeinfo         /public.php?service=nodeinfo        last;

        location = /.well-known/carddav     { return 301 /remote.php/dav/; }
        location = /.well-known/caldav      { return 301 /remote.php/dav/; }

        try_files \$uri \$uri/ =404;
    }

    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:\$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)              { return 404; }

    location ~ \.php(?:\$|/) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
        set \$path_info \$fastcgi_path_info;

        try_files \$fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$path_info;

        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
        fastcgi_param front_controller_active true;     # Enable pretty urls
        fastcgi_pass php-fpm;

        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ \.(?:css|js|svg|gif)\$ {
        try_files \$uri /index.php\$request_uri;
        expires 6M;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    location ~ \.woff2?\$ {
        try_files \$uri /index.php\$request_uri;
        expires 7d;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    location / {
        try_files \$uri \$uri/ /index.php\$request_uri;
    }
}

EOF


# Downloading NextCloud
mkdir -p /var/www/
cd /var/www/
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.7.zip
unzip nextcloud-20.0.7.zip
rm -rf nextcloud-20.0.7.zip


rm -rf /var/www/nextcloud/config/CAN_INSTALL
cat << EOF > /var/www/nextcloud/config/config.php
<?php
\$CONFIG = array (
  'instanceid' => 'ocdg8x0gyjjx',
  'passwordsalt' => 'dV6K2ZzobrxOgvqrFai6/XpInJdY0t',
  'secret' => 'vqP45Grt65aWHF8qpgqxFy0kAfMNRW+bF7CjFS4CnnrBe1wM',
  'trusted_domains' => 
  array (
    0 => 'localhost:8080',
  ),
  'datadirectory' => '/var/www/nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '20.0.7.1',
  'overwrite.cli.url' => 'http://localhost:8080',
  'dbname' => 'nextcloud',
  'dbhost' => '172.22.100.11:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'nextcloud',
  'installed' => true,
);

EOF

mkdir /var/www/nextcloud/data
touch /var/www/nextcloud/data/.ocdata

chown -R nginx:nginx /var/www/nextcloud
chmod -R 777 /var/www/nextcloud

# Some basic SELinux config:
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/nextcloud(/.*)?'
restorecon -RF /var/www/nextcloud
setsebool -P httpd_can_network_connect_db on

systemctl start php-fpm nginx

chown -R root:nginx /var/lib/php
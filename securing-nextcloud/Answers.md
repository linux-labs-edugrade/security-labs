# Answers / Guide / Cheatsheet

## SSL setup
How to create self-signed certificate
```
openssl req -newkey rsa:2048 -nodes -keyout cloud.pem -x509 -days 365 -out cloud.cert.pem
```

NGINX config `/etc/nginx/conf.d/nextcloud.conf` needs to be altered as so:
 - Edit the current server {} block to add these lines:
- Replace these lines:
```
server {
    listen 80;
    server_name localhost;
```
- With these:
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name localhost;

    # Enforce HTTPS
    return 301 https://$server_name:8443$request_uri;
}

server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name localhost;

    ssl_certificate     /path/to/certificate;
    ssl_certificate_key /path/to/key;

```

Also add this line:
```nginx
fastcgi_param HTTPS on;
```
under the line:
```nginx
fastcgi_param PATH_INFO $path_info;
```

And make sure to update `/var/www/nextcloud/config/config.php`, to include new trusted domain:
```
1 => 'localhost:8443'
```


More info here: https://docs.nextcloud.com/server/20/admin_manual/installation/nginx.html

## NGINX / PHP-FPM User setting
Under `/etc/nginx/nginx.conf`, change the `user` from `root` to something more appropriate. In our case it's `nginx`

For PHP-FPM, you can do that under `/etc/php-fpm.d/www.conf`, `user` and `group` options. If you grep, you should find them!

_NEVER_ run nginx as root!!!

## Permissions for nextcloud directories

In most "simpler" security setups, it's enough to do something like `chmod -R 755 /var/www/nextcloud`
Limits the user to writing and group & everyone to reading.

It'd probably do a little bit more harsh permissions on the `config.php`, something like `chmod 640 /var/www/nextcloud/config/config.php`

Think about the risks and protect the most important things, data and configs (password to DB and such) the rest are less important and always refer to the application manual.

Nextcloud has a great article or hardening, even a Fail2Ban setup for Nextcloud: https://docs.nextcloud.com/server/20/admin_manual/installation/harden_server.html

## Database permissions

Everything is fine with permissions on the database itself, but the `nextcloud` user is under a wildcard `%`, you can check after logging into mysql and doing:
```sql
select * from mysql.user;
```
You can either alter the user, or simply create a new one specifically for `172.22.100.10`, here you will be able to enter a new more secure password too:
```sql
drop user 'nextcloud'@'%';
create user 'nextcloud'@'172.22.100.10' identified by '<enter new password here>';
grant all privileges on nextcloud.* to 'nextcloud'@'172.22.100.10';
```

## Firewall rules

Keeping it simple for `web01`:
```bash
iptables -A INPUT  --dport 22 -j ACCEPT
iptables -A INPUT  --dport 80 -j ACCEPT
iptables -A INPUT  --dport 443 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j DROP

iptables -A OUTPUT -d 172.22.100.11 --dport 3306 -j ACCEPT
iptables -A OUTPUT -j DROP

```

For `db01`:
```
iptables -A INPUT --dport 22 -j ACCEPT
iptables -A INPUT --dport 3306 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j DROP

iptables -A OUTPUT -j DROP
```

Keep in mind after this YUM or other things won't work, so this is just concerning the services that are running.

To work with YUM, DNS, HTTPS and HTTP, add port like `80, 443, 53`.

Play around, you'll be surprised how many ports you need :)

## Scripts

I don't have any examples of these and as you know there are many ways to write the same, but here are some guidelines/tips:

  - `last` - Provides info on last enabled users
  - `nmap` - Great port scanner, use the script `ssl-cert` for expiration dates: https://nmap.org/nsedoc/scripts/ssl-cert.html
  - BONUS: You can also expiration with `openssl`, it's a bit more complicated, but bonus points whoever figures it out. Let me know!
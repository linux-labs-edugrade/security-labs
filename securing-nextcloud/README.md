# Securing NextCloud

## Vagrant file details

Vagrant up will create several VMs:
 - `web01 172.22.100.10` - The webserver where Nextcloud is stored
 - `db01 172.22.100.11` - The remote database server used for NextCloud
 - `mon01 172.22.100.12` - The monitoring server, where you monitoring scripts will run

## Objectives

You need to achieve the following:
 - Secure the Nextcloud installation on `web01`
   - Setup SSL (use a self-signed certificate)
   - Fix up permissions on the NextCloud installation, meaning fix up the users and no 777 :)
   - Make sure NGINX runs on the correct user
   - Setup Firewall rules both incoming and outgoing
   - _BONUS_: Feel free to use SELinux or AuditD to increase the systems security (not mandatory)
 - Secure the database on `db01`
   - Make sure secure passwords are used for NextCloud DB login
   - Make sure there are no wildcard users present (not hosts with the hostname `'%'`)
   - Setup Firewall rules both incoming and outgoing
   - _BONUS_: Feel free to use SELinux or AuditD to increase the systems security (not mandatory)
 - Write monitoring scripts on `mon01`
   - Write a script to check SSL certificate expiration on `web01`
   - Write a script to check all open ports on both `web01` and `db01`
   - Write a script to check last 5 logins successful to the machine
 - _BONUS_: Feel free to setup Fail2Ban on all 3 machines for SSH and if you want to, configure it for the Webserver as well!

## Getting started / Hints / Help

So some relevant information:
 - On `web01` Nextcloud installation is located in: `/var/www/nextcloud`
 - There's port forwards running from the guest ports `80 / 443` to the host machines `8080 / 8443` ports. Feel free to change those as necessary
 - NGINX configuration lives in : `/etc/nginx`
   - Site specific: `/etc/nginx/conf.d/`
 - Default login to NextCloud is : `admin / admin123`
 - Root password for the mysql database is: `security`
 - `mon01` doesn't have anything specific, feel free to configure and place scripts where ever you wish!
 - Once the vagrant is done and up, you can reach the Nextcloud on your browser, at url: http://localhost:8080

A few hints:
 - `nmap` is great tool for port scanning, has additional scripts too
 - For firewall the answers guide has `iptables` commands, but feel free to use `FirewallD`

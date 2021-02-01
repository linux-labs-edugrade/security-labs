# Kerberos setup

## Vagrant file details
Creates 2 servers: 
 - `krb01 172.22.100.10` - Your Kerberos server
 - `vm01  172.22.100.11` - Your user

It automatically downloads the EPEL repository as well as the necessary Kerberos packages.

No configuration is provided, besides the ones that come by default from the packages.

## Objectives

Configure the Kerberos services on the `krb01` server and configure `vm01` to be able to receive a ticket from the Kerberos server.

 - Create the following REALM: `EDUTEST.LOCAL`
 - Create a user in the Kerberos realm and authenticate with it on `vm01` using `kinit`.
 - Verify you received the TGT by using `klist`

 ## Hints and notables locations

 The key commands:
  - `kinit` - Used to get a ticket from a Kerberos KDC
  - `klist` - Used to list all/any tickets you have
  - `kadmin and kadmin.local` - Kerberos administration utility
  - `kdb5_util` - Used to initialize the Kerberos database.

_Always remember to check the `man` pages for all of these!!_

Key configuration files:
 - `/etc/krb5.conf` - Kerberos client configuration file
 - `/var/kerberos/krb5kdc/kdc.conf` – Configure Kerberos Key Distribution Center, so the authentication server and the ticket-granting server.
 - `/var/kerberos/krb5kdc/kadm5.acl` – Defines what users have access to the kerberos database. (Access control list)

_You can totally look up man pages for these too!_

### Final note:

`/var/kerberos/krb5kdc/kadm5.acl` should have a simple single line, to allow all admins to manage the database:
 - `*/admin@EDUTEST.LOCAL *` - Meaning you allow all principles with `/admin` to manage everything.
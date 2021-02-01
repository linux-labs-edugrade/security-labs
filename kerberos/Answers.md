# Answers!

Here you'll find a full guide to setting up a very basic Kerberos setup.

I kept everything as simple as possible, and using all the defaults provided by the packages themselves.

We'll start with configuring the `krb01` host

## Kerberos KDC setup

 - Edit `/etc/hosts` and add an additional line:
 ```
 127.0.0.1 krb01.edutest.local krb01.EDUTEST.LOCAL
 ```

 - Edit the `/etc/krb5.conf` file, and make it look like so:
```bash
# To opt out of the system crypto-policies configuration of krb5, remove the
# symlink at /etc/krb5.conf.d/crypto-policies which will not be recreated.
includedir /etc/krb5.conf.d/

[logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
    spake_preauth_groups = edwards25519
    default_realm = EDUTEST.LOCAL
    default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EDUTEST.LOCAL = {
     kdc = krb01.edutest.local
     admin_server = krb01.edutest.local
 }

[domain_realm]
 .edutest.local = EDUTEST.LOCAL
 edutest.local = EDUTEST.LOCAL
```

- After that move to the KDC config found at `/var/kerberos/krb5kdc/kdc.conf`, make it look like so:
```bash
[kdcdefaults]
    kdc_ports = 88
    kdc_tcp_ports = 88
    spake_preauth_kdc_challenge = edwards25519

[realms]
EDUTEST.LOCAL = {
     master_key_type = aes256-cts
     acl_file = /var/kerberos/krb5kdc/kadm5.acl
     dict_file = /usr/share/dict/words
     admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
     supported_enctypes = aes256-cts:normal aes128-cts:normal arcfour-hmac:normal camellia256-cts:normal camellia128-cts:normal
}
```

 - In `/var/kerberos/krb5kdc/kadm5.acl` have the following:
 ```bash
 */admin@EDUTEST.LOCAL *
 ```

Now we have both the client and KDC configured!

For the KDC to function properly it needs a database initialized to store all the principles (users, services, etc.).

To do that we execute the following command and pick a password, make sure to note it down in case you need to reimport the DB:
```bash
kdb5_util create -s 
```
Now have a database initialized!

Let's start up our services:
```
systemctl start krb5kdc
systemctl start kadmin
```
BOOM! We have KDC running!

## Setting up Kerberos principles (users, services, etc.)

On `krb01`, run `kadmin.local`:
```
addprinc username@EDUTEST.LOCAL
```
Replace `username` with one of your choice, and enter the password for the user.

After the user is created, should show something like this:
```
Principal "jonas@EDUTEST.LOCAL" created. 
```

You are ready to login! Type `exit` to quit out of `kadmin`.

And try to run 
```
kinit username
```
Replace `username` with the one you created earlier, enter your password and if all went well, `klist` should show something like this:
```
[root@krb01 ~]# klist
Ticket cache: KCM:0
Default principal: jonas@EDUTEST.LOCAL

Valid starting       Expires              Service principal
02/01/2021 03:14:58  02/02/2021 03:14:58  krbtgt/EDUTEST.LOCAL@EDUTEST.LOCAL
        renew until 02/01/2021 03:14:58
```

We have got a TICKET! Woo, our authentication setup works! Now to login from a different node.

## Setting up only Kerberos Client on `vm01`

Setup is simpler here, first install `krb5-workstation` package.

Then add your Kerberos server to your hosts file `/etc/hosts`:
```
172.22.100.10 krb01.edutest.local krb01.EDUTEST.local krb01
```

Make sure your configuration file for `/etc/krb5.conf` looks like this:
```
# To opt out of the system crypto-policies configuration of krb5, remove the
# symlink at /etc/krb5.conf.d/crypto-policies which will not be recreated.
includedir /etc/krb5.conf.d/

[logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
    spake_preauth_groups = edwards25519
    default_realm = EDUTEST.LOCAL
    default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EDUTEST.LOCAL = {
     kdc = krb01.edutest.local
     admin_server = krb01.edutest.local
 }

[domain_realm]
 .edutest.local = EDUTEST.LOCAL
 edutest.local = EDUTEST.LOCAL
```

After that is all done, simply run:
```
kinit username
```
Replace `username` with the user you created earlier and enter the password, if all goes well `klist` should return something like this:
```
[vagrant@vm01 ~]# klist
Ticket cache: KCM:0
Default principal: jonas@EDUTEST.LOCAL

Valid starting       Expires              Service principal
02/01/2021 03:14:58  02/02/2021 03:14:58  krbtgt/EDUTEST.LOCAL@EDUTEST.LOCAL
        renew until 02/01/2021 03:14:58
```

And you're done!
If you want to take it further, you can look into configuring PAM authentication with Kerberos, but that's another beast of it's own. 
Some hints in case you need to add a host principle and add it to the keytab:
 - You'll need to add each host that provides a service as principles with passwords and add them to the keytab on the Kerberos server, you do that, by entering `kadmin.local` in the Kerberos server and running the following:
 ```
 addprinc host/HOSTNAME.edutest.local
 ```
 - After creating the principle, add it to the keytab:
 ```
 ktadd -k /etc/krb5.keytab host/HOSTNAME.edutest.local
 ```
 - After than you can move onto configuring the actual service that needed the host principle configured!

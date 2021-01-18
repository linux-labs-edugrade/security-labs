# Cheats / Answers / Guide

## Google Authenticator Setup
 - google-authenticator package provides the pam module for SSH, here's documentation: https://github.com/google/google-authenticator-libpam/blob/master/README.md
 - You have to use "nullok" option in the pam.d/ssh config. As well as check the book for additional instruction on how to do it.
 - The string in ***/etc/pam.d/sshd*** would look something like: ```auth required pam_google_authenticator.so nullok ```

## SSH Keys
 - To generate: ``` ssh-keygen -t rsa -b 4096 ```
 - To copy over: ``` ssh-copy-id ```

## Patches
 - Pretty easy, yum upgrade!

## Password length enforcement
 - Check: /etc/security/pwquality.conf
 - Add: ```minlen = 16 ```
 - BONUS! : ``` man pwquality.conf ``` You can add additional options!
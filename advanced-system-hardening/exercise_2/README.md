# Exercise 2 - Configure Fail2Ban and a basic LUKS vault

## Description

Configure Fail2Ban for your SSH service.
Configure a simple LUKS vault for your files.

## Prerequisites

You need to know about:
 - Fail2Ban
 - LUKS

## Objectives

 - Install and configure ```fail2ban``` for your SSH daemon
 - Use LUKS to create a small encrypted vault for your files

## Software
 - Fail2ban
 - LUKS

## Vagrant

Creates a VM

`vm01 172.22.100.10`

# Description

Install and configure ```fail2ban``` for your `/var/log/auth.log`, to review and automatically kick/ban anyone who failed 5 attempt over 2 seconds.

Create a small empty file (1 GB), a vault, and use LUKS to encrypt it, and mount it to store all your "secret" files.
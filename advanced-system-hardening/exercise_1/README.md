# Exercise 1 - Configure NGINX Ciphers

## Description

Securing a simple SSL website, including creating your own self-signed certificate as well as using secure ciphers

## Prerequisites

You need to know about:
 - Nginx
 - SSL
 - Ciphers

## Objectives

 - Create a self-signed certificate
 - Complete the NGINX SSL configuration
 - Update the NGINX configuration with more secure ciphers

## Software

 - Nginx
 - OpenSSL

## Vagrant

Creates a VM

`vm01 172.22.100.10`

# Description

You have a basic incomplete website configuration in ```/etc/nginx/conf.d/simple-ssl.conf``` .

You need to generate a self-signed certificate using ```openssl``` toolkit, you can either go the man page route or looking up the few commands in Google.

And complete the SSL setup in that configuration file, by providing the location to the private key and certificate.

After verifying SSL works with curl : ```curl -k https://localhost``` .

Update the configuration with more secure ciphers and protocols.

A good guide: https://geekflare.com/nginx-webserver-security-hardening-guide/

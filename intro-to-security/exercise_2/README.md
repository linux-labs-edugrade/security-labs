# Exercise 2 - "Secure the box"

## Description

Basic securing of the box

## Prerequisites

You need to know about:
 - Vagrant
 - Basic hardening of the system

## Objectives

Secure the box, as best as you know.
Updates, patches, user password complexity and MFA on SSHD with Google Authenticator

## Software

 - SSH
 - Bash
 - Google Authenticator

## Vagrant

Creates a VM

`vm01 172.22.100.10`

# Description

Secure your box, accomplish the following:
 - Update your box, patches, anything else relevant
 - Secure SSH
 - Setup SSH Keys
 - Disable PasswordAuthentication
 - Enforce a minimum of 16 character password for users
 - Setup Google Authenticator for user ```hk01``` , but accept users who haven't set it up yet
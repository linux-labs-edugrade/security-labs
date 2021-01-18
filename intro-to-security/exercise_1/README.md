# Exercise 1 - "Hacking into hk01"

## Description

We're building a small script to "brute-force" SSH logins.
To understand how to protect from the attack, we can create it, simulate it.

## Prerequisites

You need to know about:
 - Vagrant
 - Bash scripting

## Objectives

Build or find a basic dictionary list, that you will run through and see if you can brute-force the password for user "hk01" via SSH.

## Software

 - SSH
 - Bash

## Vagrant

Creates a VM

`vm01 172.22.100.10`

# Description

You need to build or find a small dictionary list with common password and write a script that iterates through it and tries to login to **localhost** via SSH with the user *hk01*.
## Fail2Ban configuration

 - A great guide by DigitalOcean: https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-14-04

## LUKS encrypted vault

Here's the command to run to create a small sparse file that is LUKS encrypted: 
 - `dd if=/dev/zero of=encrypted.img bs=1 count=0 seek=1G`
 - `cryptsetup luksFormat encrypted.img`
 - `sudo cryptsetup luksOpen encrypted.img vault`
 - `sudo mkfs.ext4 /dev/mapper/vault`
 - `sudo mount /dev/mapper/vault /mnt`

After you're done:
 - `sudo umount /mnt`
 - `sudo cryptsetup luksClose vault`
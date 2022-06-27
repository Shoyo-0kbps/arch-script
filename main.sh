#!/bin/bash

## Setup Disk 
mkdir -pv ./logfiles/setup-disk.log
bash -e ./setup-disk.sh | tee ./logfiles/setup-disk.log
genfstab -U /mnt >> /mnt/etc/fstab

## Install base packages 
pacstrap /mnt linux linux-firmware base | tee ./logfiles/pacstrap.log

## Enter the chroot and setup
mkdir -pv /mnt/etc/instalation
cp ./chroot.sh /mnt/etc/instalation
arch-chroot /mnt /usr/bin/env -i /bin/bash --login +h -c "/etc/instalation/chroot.sh"

## Finish instalation
rm -rf /etc/instalation
unmount -R /mnt 
reboot

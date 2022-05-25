#!/bin/bash

mkdir -pv ./logfiles/setup-disk.log
bash -e ./setup-disk.sh | tee ./logfiles/setup-disk.log

pacstrap /mnt linux linux-firmware base | tee ./logfiles/pacstrap.log
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /usr/bin/env -i /bin/bash --login +h -c "/etc/instalation/chroot.sh"
rm -rf /etc/instalation

unmount -R /mnt 
reboot

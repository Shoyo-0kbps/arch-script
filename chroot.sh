#!/bin/bash

Select_locale ()
{
  EXIT_FLAG=0

  while [[ $EXIT_FLAG != 1 ]]; do
  
    echo "
    1 - Show all locales 
    2 - Show specific layouts avaliables ex: (en, pt, fr) 
    3 - Select one
    4 - Finish
    "
    read -p " OPTION: " OPTION

    case "$OPTION" in
      1)
        clear
        cat /etc/locale.gen | awk '(NR > 22) {print $0}' | sed -e 's/#/\t/g'
        ;;
      
      2)
        clear
        echo "ex: (en, pt, fr, de)"
        read -p "The Specific layout: " LAYOUT 
        echo
        cat /etc/locale.gen | awk  "/#$LAYOUT/{print}" | sed -e 's/#/\t/g'
        ;;
      
      3)
        clear
        echo "ex: en_US.UTF-8 UTF-8"
        read -p "Full layout: " FULL_LAYOUT
        echo $FULL_LAYOUT >> /etc/locale.gen
        ;;
      
      4)
        EXIT_FLAG=1
        ;;
      
      *) 
        EXIT_FLAG=1
        ;;
    esac
  
  done
}


ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

## Locale 
Select_locale
locale-gen


## Keyboard layout
read -p "Enter the layout: " KEYBOARD_LAYOUT
rm -f /etc/vconsole.conf
echo "KEYMAP=$KEYBOARD_LAYOUT" >> /etc/vconsole.conf


## Hostname and Hosts
read -p "Enter the host name: " HOST_NAME

cat > /etc/hosts << EOF
127.0.0.1  localhost.localdomain localhost 
::1        localhost.localdomain localhost
127.0.1.1  "${HOST_NAME}".localdomain "${HOST_NAME}"
EOF


## Users Root and New Users
echo "Enter de root password: "
passwd 

read -p "Add a new user name: " USER_NAME
useradd -G wheel -m $USER_NAME
passwd $USER_NAME


## Install base packges 
mkinitcpio -P 
pacman -S efibootmgr grub wpa_supplicant dosfstools dhcpcd mtools base-devel linux-headers openssh bash-completion git --noconfirm 


## Case use extented partition
echo 
read -p "Using extented partition? (y/n)" EXT_PART
case "$EXT_PART" in
  y|Y)
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram
    grub-mkconfig -o /boot/grub/grub.cfg 
    ;;
  n|N)
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg 
    ;;
  *)
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --no-nvram
    grub-mkconfig -o /boot/grub/grub.cfg 
    ;;
esac


## Instal and setup packages for dual boot
echo
read -p "Using Dual boot? (y/n)" DUAL_BOOT

case "$DUAL_BOOT" in
  y|Y)
    pacman -S os-prober ntfs-3g --noconfirm
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub 
    ;;
  n|N)
    ;;
  *)
    ;;
esac

## Enable base services 
systemctl enable sshd
systemctl enable dhcpcd
#systemctl enable wpa_supplicant

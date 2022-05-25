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

Select_locale
locale-gen

read -p "Enter the host name: " HOST_NAME

cat > /etc/hosts << EOF
127.0.0.1  localhost.localdomain localhost 
::1        localhost.localdomain localhost
127.0.1.1  "${HOST_NAME}".localdomain "${HOST_NAME}"
EOF

echo "Enter de root password: "
passwd 

read -p "Add a new user name: " USER_NAME
useradd -G wheel -m $USER_NAME
passwd $USER_NAME

mkinitcpio -P 

echo 
read -p "Using extented partition? (y/n)" EXT_PART
echo
read -p "Using Dual boot? (y/n)" DUAL_BOOT
pacman -S efibootmgr grub wpa_supplicant dosfstools dhcpcd mtools base-devel linux-headers openssh bash-completion git --noconfirm 

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

systemctl enable sshd
systemctl enable dhcpcd

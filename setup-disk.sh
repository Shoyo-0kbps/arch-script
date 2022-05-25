#!/bin/bash

DISKS_INFO="$(sudo fdisk -l | awk '/Disk \// {print $2,$3,$4}' | sed 's/.$//')"
DISKS_INFO=($DISKS_INFO)
NUM_DISKS=$(("${#DISKS_INFO[@]}" / 3 ))
POINT_POS=0
EXIT_FLAG=0
declare -A M_DISKS_INFO

for ((i = 0; i < "${NUM_DISKS}"; i++)); do 
  
  for ((j = 0; j < 3; j++)); do 
    M_DISKS_INFO[$i,$j]="${DISKS_INFO[ ${POINT_POS} + $j ]}"
  done
  POINT_POS=$(("${POINT_POS}" + 3))

done

Show_Disks ()
{
  echo 
  for ((i = 0; i < "${NUM_DISKS}"; i++)); do
    echo -n " Disk: "
    for ((j = 0; j < 3; j++)); do
      echo -n "${M_DISKS_INFO[$i,$j]}"
      echo -ne "\t\t"
    done
    echo

  done
}

while [[ $EXIT_FLAG != 1 ]]; do
  
  echo "
  1 - Show avaliable disks 
  2 - Formating 
  3 - Show Parted Disks 
  4 - Mounting
  5 - Finish
  "
  read -p " OPTION: " OPTION

  case "$OPTION" in
    1)
      Show_Disks
      ;;
    
    2)
      echo "ex: sda, sdb, sdc..."
      read -p "Name disk: " DISK_NAME
      cfdisk "/dev/$DISK_NAME"
      ;;
    
    3)
      echo
      lsblk | awk 'OFS = "\t\t" {print $1,$4,$7}' 
      echo
      ;;

    4)
      echo 
      echo "ex: (ext4, btrfs, xfs)"
      read -p "Filesystem for /  : " FILESYSTEM_FORMAT
      echo
      echo "ex: (sda1, sda2)"
      read -p "Select disk for /  : " DISK_SELECTED
      echo
      mkfs."${FILESYSTEM_FORMAT}" /dev/$DISK_SELECTED
      mount /dev/$DISK_SELECTED /mnt

      echo
      echo "ex: (sda1, sda2)"
      read -p "Select disk for /boot/efi  : " DISK_SELECTED
      echo
      mkfs.fat -F 32 /dev/$DISK_SELECTED
      mkdir -pv /mnt/boot/efi
      mount /dev/$DISK_SELECTED /mnt/boot/efi

      echo
      echo "ex: (ex4, btrfs, xfs)"
      read -p "Filesystem for /home : " FILESYSTEM_FORMAT
      echo
      echo "ex: (sda1, sda2)"
      read -p "Select disk for /home  : " DISK_SELECTED
      echo
      mkfs."${FILESYSTEM_FORMAT}" /dev/$DISK_SELECTED
      mkdir -pv /mnt/home
      mount /dev/$DISK_SELECTED /mnt/home

      echo
      read -p "Select disk for swap  (ex: sda1, sdb2): " DISK_SELECTED
      mkswap /dev/$DISK_SELECTED
      swapon /dev/$DISK_SELECTED
      ;;
    
    5)
      EXIT_FLAG=1
      ;;
    
    *) 
      EXIT_FLAG=1
      ;;
  esac

done

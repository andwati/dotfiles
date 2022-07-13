#!/bin/bash

# Install essential packages
pacstrap /mnt base linux linux-firmware  intel-ucode vim grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld  sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font nano

# Configure the system

# Generate fstab file
echo "generating /mnt/etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# change root(chroot) into the new system
echo "chroot into the system"
arch-chroot /mnt

# Time zone
ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc

# localization
sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Network configurations
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts

# Root password
echo root:password | chpasswd

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

# Post installation
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp 
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid


useradd -m zeno
echo zeno:password | chpasswd
usermod -aG libvirt zeno

echo "zeno ALL=(ALL) ALL" >> /etc/sudoers.d/zeno

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

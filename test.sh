#!/bin/bash
# This code is untested and intented for my computer's hardware, it may require changes

# Partitioning hard drive
echo "Partitioning disks"
sfdisk /dev/sda -d
sfdisk /dev/sda << END
size=10M,bootable 
size=2G,type=82
;
END
echo "Formatting sdb1"
mkfs.ext4 /dev/sda1
echo "Formatting sdb2"
mkswap /dev/sda2
echo "Formatting sdb3"
mkfs.ext4 /dev/sda3
echo "Turning on swap"
swapon /dev/sda2
echo "Done partitioning"

# Mounting root partition
mkdir --parents /mnt/gentoo
mount /dev/sda3 /mnt/gentoo

# Installing stage 3 tarball, skipping verification for sake of time
cd /mnt/gentoo
wget <https://bouncer.gentoo.org/fetch/root/all/releases/x86/autobuilds/20220704T170542Z/stage3-i686-openrc-20220704T170542Z.tar.xz>
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# ================= add something here for editing /mnt/gentoo/make.conf
# common flags, makeopts
# use flagsi
# ACCEPT_LICENSE="-* @FREE"

# Mounting filesystems and chrooting into new environment
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev 
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm 
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm /run/shm
chroot /mnt/gentoo /bin/bash 
source /etc/profile
export PS1="(chroot) ${PS1}"
mount /dev/sda1 /boot

# Configuring portage
emerge-webrsync
eselect news list  # not needed, just prints for user
eselect news read  # not needed, just prints for user

# Selecting profile 
eselect profile list  # not needed, just prints for user
eselect profile set 2  # compare w/ list before choosing set number
emerge --ask --verbose --update --deep --newuse @world
emerge --info | grep ^USE  # not needed, just prints for user

# Selecting imezone
ls /usr/share/zoneinfo  # not needed, just prints for user
echo "America/Los_Angeles" > /etc/timezone

# Selecting locale
# ================ add something for editing etc locale.gen
locale-gen
eselect locale list
eselect locale set 9  # compare w/ list before choosing set number
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# Kernel
emerge --ask sys-kernel/linux-firmware  # remove ask
emerge --ask sys-kernel/gentoo-sources  # remove ask
eselect kernel list  # not needed, just prints for user
eselect kernel set 1  # compare w/ list before choosing set number
emerge --ask sys-kernel/genkernel  # remove ask
# ================ add something for editing /etc/fstab
# /dev/sda1	/boot	ext4	defaults	0 2
genkernel all
ls /boot/vmlinu* /boot/initramfs*  # this should be stored for bootloader cfg

# Kernel modules
find /lib/modules/<kernel version>/ -type f -iname '*.o' -or -iname '*.ko' | less
mkdir -p /etc/modules-load.d 
# ============= add something for editing /etc/modules-load.d/network.conf 
# to add modules #####.ko, add ##### to the network.conf file
# ============= add something for editing the /etc/fstab file
# should have all of the formatting done

# Networking
# hostname and domain will be setup later





#!/bin/bash -e

install -m 644 files/regenerate_ssh_host_keys.service "$ROOTFS_DIR/lib/systemd/system/"
install -m 755 files/resize2fs_once                   "$ROOTFS_DIR/etc/init.d/"

install -d                                            "$ROOTFS_DIR/etc/systemd/system/rc-local.service.d"
install -m 644 files/ttyoutput.conf                   "$ROOTFS_DIR/etc/systemd/system/rc-local.service.d/"

install -m 644 files/50raspi                          "$ROOTFS_DIR/etc/apt/apt.conf.d/"

install -m 644 files/console-setup                    "$ROOTFS_DIR/etc/default/"

on_chroot << EOF
systemctl disable hwclock.sh
systemctl disable rpcbind
systemctl enable regenerate_ssh_host_keys
systemctl enable resize2fs_once
EOF

on_chroot << \EOF
for GRP in input spi i2c gpio; do
  groupadd -f -r $GRP
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do
  adduser $USERNAME $GRP
done
EOF

on_chroot << EOF
setupcon --force --save-only -v
EOF

on_chroot << EOF
usermod --pass='*' root
EOF

rm -f "$ROOTFS_DIR/etc/ssh/ssh_host_*_key*"

on_chroot << EOF
apt-get install -y   \
wpasupplicant        \
wireless-tools       \
firmware-atheros     \
firmware-brcm80211   \
firmware-libertas    \
firmware-ralink      \
firmware-realtek     \
raspberrypi-net-mods \
dhcpcd5
EOF

install -v -d                     "$ROOTFS_DIR/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf "$ROOTFS_DIR/etc/systemd/system/dhcpcd.service.d/"

install -v -d                               "$ROOTFS_DIR/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf "$ROOTFS_DIR/etc/wpa_supplicant/"

on_chroot << EOF
apt-get install -y vim
EOF

on_chroot << EOF
update-alternatives --set editor /usr/bin/vim.basic
EOF
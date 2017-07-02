on_chroot << EOF
apt-get install -y     \
ssh                    \
less                   \
fbset                  \
sudo                   \
psmisc                 \
strace                 \
module-init-tools      \
ed                     \
ncdu                   \
crda                   \
console-setup          \
keyboard-configuration \
debconf-utils          \
parted                 \
unzip                  \
manpages-dev           \
bash-completion        \
gdb                    \
pkg-config             \
v4l-utils              \
avahi-daemon           \
hardlink               \
ca-certificates        \
curl                   \
fake-hwclock           \
ntp                    \
usbutils               \
libraspberrypi-dev     \
libraspberrypi-doc     \
libfreetype6-dev       \
dosfstools             \
dphys-swapfile         \
raspberrypi-sys-mods   \
apt-listchanges        \
usb-modeswitch         \
apt-transport-https    \
libpam-chksshpwd
EOF

on_chroot << EOF
apt-get install --no-install-recommends -y cifs-utils
EOF

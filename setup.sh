#!/bin/bash
set -e

prerequisites() {
if [[ ! -f /usr/bin/mkarchiso ]]; then
sudo pacman -Sy --noconfirm archiso
fi

rm -rf iso
cp -r /usr/share/archiso/configs/releng iso
}

profile() {
sed -i 's|archlinux|lycusos|
s|ARCH|LycusOS|
s|^iso_publisher=.*$|iso_publisher="Sarvesh Kardekar <https://github.com/sarveshrulz>"|
s|Arch Linux|LycusOS|' iso/profiledef.sh
}

packages() {
if [[ -z $(grep 'LycusOS' iso/pacman.conf) ]]; then
cat << EOF >> iso/pacman.conf

[LycusOS-pkgs-repo]
SigLevel = Optional TrustAll
Server = https://lycusos.github.io/LycusOS-pkgs-repo/\$arch
EOF
fi

if [[ -z $(grep 'LycusOS' iso/packages.x86_64) ]]; then
cat << EOF >> iso/packages.x86_64

# LycusOS
lycusos-hooks
lycusos-installer
EOF
fi
}

bootloader() {
rename arch lycusos iso/{syslinux/*,efiboot/loader/entries/*}

sed -i 's|Arch Linux|LycusOS|g' iso/{syslinux/*,efiboot/loader/entries/*}
sed -i 's|archiso|lycusosiso|g' iso/syslinux/{lycusosiso_pxe.cfg,lycusosiso_sys.cfg,syslinux.cfg} iso/efiboot/loader/loader.conf

cp -f files/splash.png iso/syslinux/splash.png
}

misc() {
echo "lycusos" > iso/airootfs/etc/hostname

cat << EOF > iso/airootfs/etc/motd
  _                           ____   _____ 
 | |                         / __ \ / ____|
 | |    _   _  ___ _   _ ___| |  | | (___  
 | |   | | | |/ __| | | / __| |  | |\___ \ 
 | |___| |_| | (__| |_| \__ \ |__| |____) |
 |______\__, |\___|\__,_|___/\____/|_____/ 
         __/ |                             
        |___/                                                      

Welcome! Enter \`lycusos-installer\` to start the installation.

EOF

sed -i 's|^exec.*$|echo W.I.P|' iso/airootfs/usr/local/bin/Installation_guide
}

# Main
prerequisites
profile
packages
bootloader
misc

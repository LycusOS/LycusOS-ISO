#!/bin/bash

prerequisites() {
if [[ ! -f /usr/bin/mkarchiso ]]; then
sudo pacman -Sy --noconfirm archiso
fi

if [[ ! -d iso ]]; then
cp -r /usr/share/archiso/configs/releng iso
fi
}

profile() {
sed -i 's|archlinux|lycusos|
s|ARCH|LycusOS|
s|^iso_publisher=.*$|iso_publisher="Sarvesh Kardekar <https://github.com/sarveshrulz>"|
s|Arch Linux|LycusOS|' iso/profiledef.sh
}

packages() {
if [[ -z $(grep 'LycusOS' iso/pacman.conf) ]] ; then
cat << EOF >> iso/pacman.conf

[LycusOS-pkgs-repo]
SigLevel = Optional TrustAll
Server = https://lycusos.github.io/LycusOS-pkgs-repo/\$arch
EOF
fi

if [[ -z $(grep 'LycusOS' iso/packages.x86_64) ]] ; then
cat << EOF >> iso/packages.x86_64

# LycusOS
lycusos-hooks
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

EOF

sed -i 's|^exec.*$|echo W.I.P|' iso/airootfs/usr/local/bin/Installation_guide
}

# Main
prerequisites
profile
packages
bootloader
misc

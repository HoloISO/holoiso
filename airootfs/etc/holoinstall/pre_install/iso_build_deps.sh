#!/bin/zsh
# Prepares ISO for packaging

# Remove useless shortcuts for now
mv /etc/skel/Desktop/Return.desktop /etc/holoinstall/post_install_shortcuts

# Add a liveOS user
ROOTPASS="holoconfig"
LIVEOSUSER="liveuser"

echo -e "${ROOTPASS}\n${ROOTPASS}" | passwd root
useradd --create-home ${LIVEOSUSER}
echo -e "${ROOTPASS}\n${ROOTPASS}" | passwd ${LIVEOSUSER}
echo "${LIVEOSUSER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${LIVEOSUSER}
chmod 0440 /etc/sudoers.d/${LIVEOSUSER}
usermod -a -G rfkill ${LIVEOSUSER}
usermod -a -G wheel ${LIVEOSUSER}
# Begin coreOS bootstrapping below:

# Init pacman keys
pacman-key --init
pacman -Sy

# Install desktop suite
pacman -Rcns --noconfirm pulseaudio xfce4-pulseaudio-plugin pulseaudio-alsa
pacman -Rdd --noconfirm sddm
pacman --overwrite="*" --noconfirm -S holoiso-main holo/filesystem holoiso-updateclient wireplumber flatpak packagekit-qt5 rsync unzip sddm-wayland dkms steam-im-modules systemd-swap ttf-twemoji-default ttf-hack ttf-dejavu pkgconf pavucontrol partitionmanager gamemode lib32-gamemode cpupower bluez-plugins bluez-utils
mv /etc/xdg/autostart/steam.desktop /etc/xdg/autostart/desktopshortcuts.desktop /etc/skel/Desktop/steamos-gamemode.desktop /etc/holoinstall/post_install_shortcuts
wget https://gdrivecdn.thevakhovske.pw/6:/holoiso/os/x86_64/lib32-nvidia-utils-515.57-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
pacman -U --noconfirm /etc/holoinstall/post_install/pkgs/lib32-nvidia-utils-515.57-1-x86_64.pkg.tar.zst

# Enable stuff
systemctl enable sddm NetworkManager systemd-timesyncd cups bluetooth sshd

# Download extra stuff
mkdir -p /etc/holoinstall/post_install/pkgs
wget https://gdrivecdn.thevakhovske.pw/6:/holostaging/os/x86_64/linux-holoiso-5.18.1.holoiso20220606.1822-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
wget https://gdrivecdn.thevakhovske.pw/6:/holostaging/os/x86_64/linux-holoiso-headers-5.18.1.holoiso20220606.1822-1-x86_64.pkg.tar.zst -P /etc/holoinstall/post_install/pkgs
wget $(pacman -Sp win600-xpad-dkms) -P /etc/holoinstall/post_install/pkgs_addon
wget $(pacman -Sp linux-firmware-neptune) -P /etc/holoinstall/post_install/pkgs_addon

# Workaround mkinitcpio bullshit so that i don't KMS after rebuilding ISO each time and having users reinstalling their fucking OS bullshit every goddamn time.
rm /etc/mkinitcpio.conf
mv /etc/mkinitcpio.conf.pacnew /etc/mkinitcpio.conf 
rm /etc/mkinitcpio.d/* # This removes shitty unasked presets so that this thing can't overwrite it next time
cp /etc/holoinstall/post_install/mkinitcpio_presets/linux-neptune.preset /etc/mkinitcpio.d/ # Yes. I'm lazy to use mkinitcpio-install. Problems? *gigachad posture*

# Prepare thyself
chmod +x /etc/holoinstall/post_install/install_holoiso.sh
chmod +x /etc/skel/Desktop/install.desktop
chmod 755 /etc/skel/Desktop/install.desktop

# Remove stupid stuff on build
rm /home/${LIVEOSUSER}/steam.desktop /home/${LIVEOSUSER}/steamos-gamemode.desktop

# Remove this shit from post-build
rm -rf /etc/holoinstall/pre_install
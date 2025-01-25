#! /bin/bash

# install scripts on system path
INSTALL_DIR="/usr/local/bin"
read -p "Install target? [${INSTALL_DIR}]: " CUSTOM_DIR && [[ $CUSTOM_DIR == '' ]] || INSTALL_DIR=${CUSTOM_DIR}
cp -n set_next_boot.sh ${INSTALL_DIR}/set_next_boot
cp -n reboot_to.sh ${INSTALL_DIR}/reboot_to

# desktop shortcut for windows reboot
SKIP=0
SHORTCUT_DIR="/usr/share/applications"
read -p "Install desktop shortcut for Windows OS? [Y/n]" confirm && [[ $confirm == '' || $confirm == [yY] || $confirm == [yY][eE][sS] ]] || SKIP=1
if [[ ${SKIP} == 0 ]]; then
    # install windows icon
    # cf. https://martin.hoppenheit.info/blog/2016/where-to-put-application-icons-on-linux/
    INSTALL_DIR="/usr/share/icons/hicolor/scalable/apps/"
    cp resources/windows11-logo-symbolic.svg ${INSTALL_DIR}
    NAME='Windows' ENTRY='auto-windows' ICON='windows-logo-dark' envsubst < resources/reboot_into.desktop.in > ${SHORTCUT_DIR}/reboot_to_windows.desktop
fi

# desktop shortcut for firmware reboot
SKIP=0
read -p "Install desktop shortcut for Firmware Setup? [Y/n]" confirm && [[ $confirm == '' || $confirm == [yY] || $confirm == [yY][eE][sS] ]] || SKIP=1
if [[ ${SKIP} == 0 ]]; then
    NAME='Firmware Setup' ENTRY='auto-reboot-to-firmware-setup' ICON='application-x-firmware-symbolic' envsubst < resources/reboot_into.desktop.in > ${SHORTCUT_DIR}/reboot_to_firmware_setup.desktop
fi

# custom desktop shortcuts
SKIP=1
read -p "Install additional desktop shortcuts? [y/N]" confirm && [[ $confirm == '' || $confirm == [nN] ]] || SKIP=0
while [[ ${SKIP} == 0 ]]; do
    read -p "Entry? " ENTRY
    read -p "Name? " NAME
    ICON='system-reboot-symbolic'
    read -p "Icon [${ICON}]? " CUSTOM_ICON && [[ $CUSTOM_ICON == '' ]] || ICON=${CUSTOM_ICON}
    NAME=${NAME} ENTRY=${ENTRY} ICON=${ICON} envsubst < resources/reboot_into.desktop.in > ${SHORTCUT_DIR}/reboot_to_${ENTRY}.desktop
    read -p "Install additional desktop shortcuts? [y/N]" confirm && [[ $confirm == '' || $confirm == [nN] ]] || SKIP=0
done

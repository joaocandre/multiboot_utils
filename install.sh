#! /bin/bash

# install scripts on local path
INSTALL_DIR="/usr/local/bin"
cp set_next_boot.sh ${INSTALL_DIR}
cp reboot_into_windows.sh ${INSTALL_DIR}

# install windows icon
# cf. https://martin.hoppenheit.info/blog/2016/where-to-put-application-icons-on-linux/
INSTALL_DIR="/usr/share/icons/hicolor/scalable/apps/"
cp resources/windows-logo-dark.svg ${INSTALL_DIR}

# install desktop shortcut
INSTALL_DIR="/usr/share/applications"
cp reboot_into_windows.desktop ${INSTALL_DIR}

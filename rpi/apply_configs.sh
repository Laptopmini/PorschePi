#!/usr/bin/env bash
# This script is meant to be executed from the Pi
set -e

echo "Applying configs..."

# Apply OpenAuto config
cp -f openauto_system.ini /home/pi/.openauto/config/openauto_system.ini
cp -f openauto_applications.ini /home/pi/.openauto/config/openauto_applications.ini
cp -f openauto.desktop /usr/share/applications/openauto.desktop
cp -f autobox-icon.png /home/pi/.openauto/autobox/logo.png
rm -f ~/Desktop/openauto

# Apply WaveShare config
cat waveshare_config.txt >> /boot/config.txt
sed -i 's/OPENAUTO_VIDEO_ORIENTATION=0/OPENAUTO_VIDEO_ORIENTATION=270/g' /etc/systemd/system/openautopro.splash.service

# Change Splash animation
cp -f splash.h264 /usr/share/openautopro/splash1.h264
cp -f splash.h264 /usr/share/openautopro/splash2.h264

# Apply Desktop configuration
cp -f desktop.conf /home/pi/.config/lxsession/LXDE-pi/desktop.conf

# Enable Bluetooth
sed -i 's/dtoverlay=disable-bt/#dtoverlay=disable-bt/g' /boot/config.txt

# Fix Audio Keyboard Commands
cp -f lxde-pi-rc.xml /etc/xdg/openbox/lxde-pi-rc.xml

# Enable Restore Settings Service
chown root:root restore-settings.sh
cp -f restore-settings.service /etc/systemd/system
chown root:root /etc/systemd/system/restore-settings.service
mkdir -p /etc/systemd/system/multi-user.target.wants
ln -fs /etc/systemd/system/restore-settings.service /etc/systemd/system/multi-user.target.wants/restore-settings.service
systemctl enable restore-settings.service
systemctl start restore-settings.service

# Enable Power Monitor Service
pip3 install python-dotenv
chown root:root power-monitor.py
cp -f power-monitor.service /etc/systemd/system
chown root:root /etc/systemd/system/power-monitor.service
ln -fs /etc/systemd/system/power-monitor.service /etc/systemd/system/multi-user.target.wants/power-monitor.service
systemctl enable power-monitor.service
systemctl start power-monitor.service

# Install Beocreate Tools
sh beocreate/install.sh

echo "Done!"

halt
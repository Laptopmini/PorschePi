#!/usr/bin/env bash
# This script is meant to be executed from the Pi
set -e

TARGET=/boot/porschepi/beocreate
if [ "$1" != "" ]; then 
 TARGET=$1
fi

echo "Installing BeoCreate Tools using $TARGET"
cd $TARGET

# Create ALSA Config
rm -rf /etc/asound.conf
cat <<EOT >/etc/asound.conf
# asound.conf.dmix_softvol w/ microphone changes
defaults.pcm.rate_converter "samplerate"

defaults.pcm.card 0
defaults.ctl.card 0

pcm.hifiberry {
  type hw
  card 0
  device 0
}
pcm.dmixer {
  type dmix
  ipc_key 1024
  ipc_perm 0666
  slave.pcm "hifiberry"
  slave {
    period_time 0
    period_size 2048
    buffer_size 32768
    rate 192000
    format S32_LE
  }
  bindings {
    0 0
    1 1
  }
}
ctl.dmixer {
  type hw
  card 0
}
pcm.softvol {
  type softvol
  slave.pcm "dmixer"
  control {
    name "Master"
    card 0
  }
  min_dB -90.2
  max_dB 0.0
}
pcm.mic {
  type plug
  slave {
    pcm "hw:1,0"
  }
}
pcm.!default {
  type asym
  playback.pcm "softvol"
  capture.pcm "mic"
}
EOT

# Update config.txt
sed -i 's/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g' /boot/config.txt
sed -i 's/dtparam=audio=off/#dtparam=audio=off/g' /boot/config.txt
sed -i 's/dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d,audio=off/g' /boot/config.txt
printf "# Hifiberry Beocreate\n" >>/boot/config.txt
echo [all] >>/boot/config.txt
echo force_eeprom_read=0 >>/boot/config.txt
echo dtoverlay=hifiberry-dac >>/boot/config.txt
echo dtparam=i2c1=on >>/boot/config.txt

# Install Tools
mkdir -p /opt/hifiberry/bin
cp -f alsa-mode /opt/hifiberry/bin/
cp -f debuginfo /opt/hifiberry/bin/
cp -f mute-beocreate /opt/hifiberry/bin/
cp -f reset-volume /opt/hifiberry/bin/
cp -f unmute-beocreate /opt/hifiberry/bin/

# Install DSP Toolkit
bash <(curl https://raw.githubusercontent.com/hifiberry/hifiberry-dsp/master/install-dsptoolkit)

echo "Finished installing tools!"

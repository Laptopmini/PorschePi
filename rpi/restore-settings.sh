#!/usr/bin/env bash
# This script is meant to be executed from the Pi
set -e
. /boot/porschepi/settings.conf

# Set DSP Volume
dsptoolkit set-volume $VOLUME%
# Make sure the default audio output is correct
pacmd set-default-sink "alsa_output.platform-soc_sound.stereo-fallback"
# Play/Pause -> B
sudo -u pi xmodmap -display :0.0 -e 'keycode 172 = b'

echo "Restored Settings!"
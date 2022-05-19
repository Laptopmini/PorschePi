#!/usr/bin/env bash
# This script is meant to be executed from the Pi
set -e
source /boot/porschepi/settings.conf

echo "Setting up BeoCreate soundcard..."

# Setup DSP Profile
dsptoolkit install-profile https://raw.githubusercontent.com/bang-olufsen/create/master/Beocreate2/beo-dsp-programs/beocreate-universal-10.xml
dsptoolkit reset
dsptoolkit set-volume $VOLUME%

echo "Done!"
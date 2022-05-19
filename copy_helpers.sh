#!/usr/bin/env bash
set -e

SOURCE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BOOT=$1
FOLDER=porschepi
TARGET=$BOOT/$FOLDER

echo "Copying helpers to $TARGET..."

# Init
rm -rf $TARGET
mkdir $TARGET

# Copy
cp -R $SOURCE/beocreate/tools $TARGET/beocreate
cp $SOURCE/beocreate/bang-olufsen-logo.png $TARGET
cp $SOURCE/openauto/autobox-icon.png $TARGET
cp $SOURCE/openauto/menu-icon.png $TARGET
cp $SOURCE/openauto/openauto_applications.ini $TARGET
cp $SOURCE/openauto/openauto_autobox_plugin.zip $TARGET
cp $SOURCE/openauto/openauto_system.ini $TARGET
cp $SOURCE/openauto/openauto.desktop $TARGET
cp -R $SOURCE/rpi $TARGET
cp $SOURCE/waveshare/config.txt $TARGET/waveshare_config.txt

echo "Done!"

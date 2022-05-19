#!/usr/bin/python3 -u
# Source: https://bluewavestudio.io/community/thread-1128.html
# This script was originaly written by 765GHF, many thanks to them.

import os
import RPi.GPIO as GPIO
import subprocess
import sys
import time
from dotenv import load_dotenv

# Configuration File
CONF = "/boot/porschepi/settings.conf"

# Load configuration
load_dotenv(CONF)

if not int(os.getenv("POWER_MONITOR_ENABLED", "0")):
	print("Power monitoring disabled in " + CONF + ". Terminating.")
	sys.exit() 

# Enable debug verbose output
DEBUG = int(os.getenv("POWER_MONITOR_DEBUG", "0"))

# GPIO / BCM 16 - physical pin 32 on Beocreate
PORT = 16

# Shutdown delay in seconds (4.5 mins)
SHUTDOWN_DELAY = 270

# Number of seconds after ignition returns to cancel shutdown
CANCEL_SHUTDOWN = 5

# specify pin numbering format
GPIO.setmode(GPIO.BCM)

# set pin to input, set pull up resistor so it reads high
GPIO.setup((PORT), GPIO.IN, pull_up_down=GPIO.PUD_UP)

IGN_STATUS = 1
SHUTDOWN = 0
IGN_OFF_TIME = 0
IGN_OFF_LAST_SEEN = 0
NOW = 0

def setDisplayEnabled( on ):
	ARG = "on"
	if not on:
		ARG = "off"
	try:
		subprocess.run("XAUTHORITY=/home/pi/.Xauthority xset -display :0.0 dpms force " + ARG, shell=True)
	except subprocess.CalledProcessError as displaycmd:
		print("Turning ", ARG, " display failed with error code: ", displaycmd.returncode)
	return

def setSoundEnabled( on ):
	CMD = "unmute"
	if not on:
		CMD = "mute"
	try:
		subprocess.run(["/opt/hifiberry/bin/" + CMD + "-beocreate"])
	except subprocess.CalledProcessError as soundcmd:
		print("Attempt to ", CMD, " sound failed with error code: ", soundcmd.returncode)
	return

# Make sure Sound & Display are enabled
setSoundEnabled(True)
setDisplayEnabled(True)

while True:
	NOW = time.time()

	# Get the status of the ignition
	IGN_UP = GPIO.input(PORT)
 
	# Ignition switched off? Then set shutdown flag and igntion off time
	if not IGN_UP and not SHUTDOWN:
		print("Ignition switched off, setting shutdown flag!")
		SHUTDOWN = 1
		IGN_OFF_TIME = NOW
		setSoundEnabled(False)
		setDisplayEnabled(False)

	# Increment this counter while ignition is off
	if not IGN_UP and SHUTDOWN:
		IGN_OFF_LAST_SEEN = NOW

	# If ignition is off, check if shutdown delay time reached
	if (SHUTDOWN and not IGN_UP and ((NOW - IGN_OFF_TIME) > SHUTDOWN_DELAY)):
		print("Shutdown delay of", SHUTDOWN_DELAY, "seconds reached, shutting down!")
		try:
			subprocess.check_output(["shutdown", "-h", "now", "--no-wall"])
		except subprocess.CalledProcessError as shutdowncmd:
			print("Shutdown failed with error code: ", shutdowncmd.returncode)
			break
	
	# Cancel shutdown if power has been back for CANCEL_SHUTDOWN seconds
	if ((NOW - IGN_OFF_LAST_SEEN) >= CANCEL_SHUTDOWN ) and SHUTDOWN:
		print("Ignition has been back for ", CANCEL_SHUTDOWN, " seconds, shutdown flag reset.")
		SHUTDOWN = 0
		IGN_OFF_TIME = 0
		IGN_OFF_LAST_SEEN = 0
		setSoundEnabled(True)
		setDisplayEnabled(True)

	if DEBUG:
		STATUS = GPIO.input(PORT)
		print("Pin status is: ", STATUS)
		print("IGN_UP is set to: ", IGN_UP)
		print("SHUTDOWN is set to: ", SHUTDOWN)
		if SHUTDOWN:
			print("Igntion off time is: ", IGN_OFF_TIME)
			print("Igntion off last seen time is: ", IGN_OFF_LAST_SEEN)
			print("Current time is: ", NOW)
			print("Elapsed time is: ", (NOW - IGN_OFF_TIME))

	time.sleep(1)

if DEBUG:
	print("Exiting")

GPIO.cleanup()
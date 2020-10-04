# CarPi: Car computer Project
The goal of this project is to create a computer that interacts with my car and provides automation, information, diagnostics, and other technological niceties.
- Reverse camera
	- Automatic display when in reverse
	- Recording reverse camera feed
- Android Auto
	- OpenAutoPro
	- OK Google voice commands
	- Maps & Directions
	- Integration with car audio
- Car radio control
	- Bluetooth commands/connection
	- Play music library from computer
- Other cameras
	- front internal
	- blindspots
	- recording of feeds
	- syncronize/download dashcam data
- LTE connectivity
	- Remotely update scripts
	- (Private/secure) location tracking/querying
- Automation/Controls
	- Window control
	- AC control
	- Headlights (light sensor)
- Rear sensors
	- Integrate sensors with computer
- Replace/augment dashboard
- Odometer tracking
	- Oil changes
	- trip lengths
	- gas mileage

This page is a journal of the design and installation process.

# Hardware
- Raspberry Pi 4B+
- EasyCap 4
	- 4 video inputs, 1 audio input
	- Many options on eBay (~$9)
	- Mine identified as Somagic clone
	- This can be risky, 
- Reverse Camera
	- Generic CMOS analog camera on Amazon
	- These are pretty cheap (~$10-50), any with a yellow rca cable should work
- GPS
	- I chose this one: https://smile.amazon.com/gp/product/B073P3Y48Q
	- Check reviews for raspberry pi compatibility

# Software

## Powershell
This is my preferred shell  
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#raspbian

## Somagic

https://code.google.com/archive/p/easycap-somagic-linux/wikis/GettingStarted.wiki  

https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/easycap-somagic-linux/somagic-easycap_1.1.tar.gz  

https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/easycap-somagic-linux/somagic-easycap-tools_1.1.tar.gz  

### somagic-capture source package
Install build and usage dependencies: make, gcc, libusb-1.0-0 (and development headers), libgcrypt11 (and development headers), mplayer (optional), lsusb (optional).
```bash
sudo apt-get install make gcc libusb libgcrypt11 mplayer lsusb
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/easycap-somagic-linux/somagic-easycap_1.1.tar.gz
tar xvf somagic-easycap_VERSION.tar.gz
cd somagic-easycap-tools_1.1
make
sudo make install
```
See the README file for additional instructions.


### somagic-capture-tools source package

```bash
sudo apt-get install make gcc libusb libgcrypt11 mplayer lsusb
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/easycap-somagic-linux/somagic-easycap_1.1.tar.gz
tar xvf somagic-easycap_VERSION.tar.gz
cd somagic-easycap-tools_1.1
make
sudo make install
```
Compile kernel module to get /dev/videoX device(s): https://github.com/pimartos/easycap-somagic-linux/issues/30

## USB2CAN
https://github.com/krumboeck/usb2can  
https://www.8devices.com/wiki/usb2can:compile-raspberry  
https://www.8devices.com/media/products/usb2can_korlan/downloads/Korlan_USB2CAN_User_Guide.pdf  

### Build
```powershell
sudo apt-get update
sudo apt-get install git raspberrypi-kernel raspberrypi-kernel-headers can-utils
git clone https://github.com/krumboeck/usb2can.git
cd usb2can
sudo make && sudo make install

# Install may fail with “Warning: modules_install: missing 'System.map' file. Skipping depmod”. See https://raspberrypi.stackexchange.com/questions/761/how-do-i-load-a-module-at-boot-time, but the DKMS should supercede this
sudo reboot

# Runtime loading of modules:
cd ~/usb2can
modprobe can_raw
modprobe can_dev
insmod usb_8dev.ko

#To remove:
rmmod usb_8dev

# Automatic: add can, can_raw, and can_dev to /etc/modules

#DKMS (auto rebuild of module on kernel updates):
git archive --prefix=usb2can-1.0/ -o /usr/src/usb2can-1.0.tar HEAD
cd /usr/src
tar -xvf usb2can-10.tar
dkms add -m usb2can -v 1.0 --verbose

# Build the module, e.g.
dkms build -m usb2can -v 1.0 --verbose
# Install the module, e.g.
dkms install -m usb2can -v 1.0 --verbose

# Control interface (startup script):
ip link set can0 up type can bitrate 500000 sample-point 0.875
ip link set can0 down
```
USB2CAN has 3 LEDs: INFO, STAT, and PWR. When interface is connected and up, INFO and PWR are lit. Otherwise, STAT and PWR are lit. INFO flashes on initial connection.

# Ideas
- Auotmatic check engine light info popup
- Basic OBD2 commands (look at python-obd)
- https://python-obd.readthedocs.io/en/latest/Command%20Tables/
	- Atz -reset
    - Atl1 -enable line feeds
    - Ath1 - enable display headers (may not want; prepends headers to return values)
    - Atsp0 - automatic detection of protocol


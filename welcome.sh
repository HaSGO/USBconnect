#!/bin/bash	
#configuration info
rootUsbConnect="/root/projects/usbConnect"
fCertificate="/media/USBkeys/.HaSGO/certificate.txt"
fPasswd="./certificate/pswd"

oldDir=$(pwd)
cd "$rootUsbConnect"
echo "$1" > "welcome.log"
#echo "User execute:$USER" >> welcome.log
mount "$1" "/media/USBkeys" 2>> "welcome.log"
./checkUser.rb "$fPasswd" "$fCertificate" "$1" 2>> "welcome.log"

umount "/media/USBkeys" 2>> "welcome.log"
cd "$oldDir"

#!/bin/bash
export SUMO_TEST_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"

export TEST_HOST_1_IF="enx000fc9119ecb" # Replace with your own local interface connected with the test host 1
export TEST_HOST_1_IF_IP="192.168.0.31" # Replace with IP of your own local interface connected with the test host 1
export TEST_HOST_1_IP="192.168.0.30"    # Replace with the IP of your own test host 1
export TEST_HOST_1_PASS="yourpassword"      # Put here your own password to remote access test host 1
export FTPADDR="ftp.slashetc.fr"        # Put here your own test ftp address here
export FTPLOGIN="slash2438072"          # Put here your own ftp login
export FTPSITE="ftp://${FTPLOGIN}@${FTPADDR}"
export FTPPASS="yourpassword"           # Put here your own ftp pass
export SSHLOGIN="michel"                # Put here your own ssh login for ssh testing
export SSHHOST="riffian"                # Put here your own ssh pass for ssh testing
export VERA_DEVICE="sdd1"               # Put here the default device containing a VERA formated stick for test mntvera. Can be overriden at runtime except if option '--force-defaults' is 
export LUKS_DEVICE="sdd1"               # Put here the default device containing a LUKS formated stick for test mntluks. Can be overriden at runtime except if option '--force-defaults' is 
export DISK_FORMAT_PART_FLASH_TEST="sdb"        # Put here the device path of the disk used for format, partioning and flash tests
export DISKPART_FORMAT_PART_FLASH_TEST="sdb1"   # Put here the device path of the partition used for format, partioning and flash tests
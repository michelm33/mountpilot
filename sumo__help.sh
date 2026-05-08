#!/bin/bash
###############################################################################
# 
# MountPilot & sumo backend control script
# 
# Copyright (c) 2024-2026 Michel Mehl.
# All rights reserved. 
# Tous droits réservés (France).
# 
# License terms written down in file LICENSE.txt
# Les termes de la licence sont détaillés dans le fichier LICENSE.txt
# 
# Release file path: sumo__help.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-07 16:42:36.107205475 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file contains the code related the usage and help documentation.
#
# ------------------------------------------------------------------------------
# 
# Report bugs and suggestions: 
#     assistance@slashetc.fr
# 
# Specific or corporate requirements or extensions: 
#     info@slashetc.fr
# 
# The author is overall not required to provide maintenance or support 
# outside specific commercial terms agreed.
# 
###############################################################################

:<<'EOF'
Version and copyright display callback (-h)
EOF

Sumo__version() {
cat << EOF
MountPilot sumo ${SUMO__VARS["SUMO__VERSION"]}

$(cat "${SUMO__VARS["SUMO__MY_DIR"]}/COPYRIGHT.txt"|tail -n+4)

Written by Michel Mehl

EOF
}

:<<'EOF'
Help display callback (-h) for usage
EOF

Sumo__help() {
  echo
  Sumo__usage
}

:<<'EOF'
Manual display callback (-h)
EOF

#$(basename ${__SHELL_SRC_NAME__}) - A central mount and unmount control tool for heterogeneous data sources and simple disk files creation.

Sumo__man() {
cat << EOF | less
*SYNOPSIS*

$(Sumo__susage_without_options)
$(Sumo__usage_args)

OPTIONS:

$(_soptions SUMO__OPTION_LIST_DESC SUMO__OPTION_LIST_SDESC SUMO__OPTION_LIST_ARGS SUMO__OPTION_LIST_ARGS_TYPE SUMO__OPTION_LIST_INTERN)

*DESCRIPTION*

Mountpilot integrates into one tool various mount methods existing on Linux systems, 
while also providing an live interface for monitoring and interacting with running or past mounts.

The integrated mount functions enable to mount on the local file system a large variety of data sources 
from a single unified command-line interface (CLI). Once 'mounted', the files of the source can be 
accessed locally from the mountpoint folder, as if they were local files. Data sources may be as diverse 
as local disks, mobile devices, network connections and disk files.

The mount functions are supplemented by auto-installation of dependency packages and 
auto-login setups to access remote sources.

In addition, it also provides basic disk creation and manipulation functions, with seamless handling of encryption.

sumo is MountPilot's back-end command line tool to perform the mount/unmount operations and disk operations. 
Most operations are actually achieved by sumo, which is either launched manually by the user or 
launched in background from the dashboard.

Passing option '-i-' launches MountPilot itself, i.e. the dashboard on the current terminal.

This manpage mainly focuses on the command usage and options documentation, as well as concret examples to use the tool.
The full documentation is available at address https://slashetc.fr/mountpilot


SYSTEM PRIVILEDGES

  This script requires to execute most underlying system command with root priviledges.
  It should be ensured the user is granted sudo. It is recommended to deactivate password entry
  and have 24h timeout


$(_options SUMO__OPTION_LIST_DESC SUMO__OPTION_LIST_ARGS SUMO__OPTION_LIST_INTERN)

*LIMITATIONS*

File system labels containing spaces are not supported.

$(Sumo__examples)

Report bugs to <michel.mehl@slashetc.fr>

EOF
}

:<<'EOF'
Returns the examples for the man page.
It is read from a file named EXAMPLES.txt located in the sumo's root folder. 
EOF

Sumo__examples() {
  local exampleFile="${SUMO__VARS["SUMO__MY_DIR"]}/EXAMPLES.txt"
  if [ -f "${exampleFile}" ] ; then
    cat "${exampleFile}"
  fi
}

:<<'EOF'
Short usage display callback 
EOF

Sumo__susage() {
cat << EOF
$(Sumo__susage_without_options)

OPTIONS:

$(_soptions SUMO__OPTION_LIST_DESC SUMO__OPTION_LIST_SDESC SUMO__OPTION_LIST_ARGS SUMO__OPTION_LIST_ARGS_TYPE SUMO__OPTION_LIST_INTERN)
EOF
}

Sumo__susage_without_options() {
  local __cmdbasename="$(basename $0)"
cat << EOF
Usage: ${__cmdbasename} OPTIONS <block device path | disk file name| overlay path | ADB URL | NFS URL | FTP URL | SSH URL | SAMBA URL | UNC address | HTTP address> [<mount folder>]
or: ${__cmdbasename} OPTIONS -L|--label= <volume label> [<mount folder>]  
or: ${__cmdbasename} OPTIONS -u <mount point folder> 
or: ${__cmdbasename} OPTIONS -u -L <volume label> 
or: ${__cmdbasename} OPTIONS -u <block device path | disk file name| overlay path | ADB URL | NFS URL | FTP URL | SSH URL | SAMBA URL | UNC address | HTTP address> 
or: ${__cmdbasename} OPTIONS -F|--format-disk -t <filesystem type> <block device path>
or: ${__cmdbasename} OPTIONS -B|--flash-disk= <disk image> <block device path>
or: ${__cmdbasename} OPTIONS -P|--part-disk= <partition GUID>
or: ${__cmdbasename} OPTIONS [-l] [coma-separated list of filter names]
or: ${__cmdbasename} OPTIONS [-i]
EOF
}

:<<'EOF'
Usage display callback 
EOF

Sumo__usage() {
        local susage_txt="$(Sumo__susage|grep -v -E ^Basic\ options\:|grep -v -E ^[[:blank:]]*-o|grep -v -E ^[[:blank:]]*-h)"  #|grep -v -E ^Options\:|grep -- -v -E ^\ -f|grep -- -v -E ^\ -h)"
cat << EOF
${susage_txt}
$(Sumo__usage_args)
EOF
}

Sumo__usage_args() {
cat << EOF

Arguments:

 <block device path>  e.g. /dev/sda, /dev/sdb1, /dev/loop23
 <disk file>          disk file path (.img,.qcow2,.vdi,.vera,.luk). If inexistent, it is proposed to create it.
 overlay path         <upper_dir>><lower_dir>
                      an overlay file system where the upper directory and the lower directory are separated by '>'.
                      When there are multiple lower dirs, the lowest is always put at the right most position and 
                      all dirs are separated by '>' as well. 
                      Note: The 'work' directory as documented for overlay systems is transparently created at the same level dir as 'upperdir' 
 ADB URL              adb://usb
 NFS URL              nfs://<host>:<remote_dir>
 FTP URL              ftp://[<login>@]<host>[:<port>]
 SSH URL              [ssh://]<login>@<host>[:<port>]
 SAMBA URL            [smb:]//[<login>:[<password>]@]<host>/<share>
 UNC address          //<host>/<share>
 HTTP URL             https://<host>. Only https://drive.google.com supported. 
 <mount folder>       Target mount point (it is a folder).
EOF
}

:<<'EOF'
Displays help contextual information for USB devices.
EOF

Sumo__help_usb() {
cat << EOF
 $(tput smul)Help sheet USB$(tput rmul)

 USB 1:   12 MBit/s or 1500 Ko/s
 USB 2:   480 MBit/s or 60000 Ko/s or 60 Mo/s
 USB 3.0: 5000 MBit/s or 625000 Ko/s or 625 Mo/s 
 USB 3.1: speed 10000 MBit/s or 1250000 Ko/s or 1250 Mo/s  

 USB 3.0 also referred to as USB3.1 gen. 1.
 USB 3.1 also referred to as USB3.1 gen. 2
EOF
}


:<<'EOF'
Displays help contextual information for USB devices.
EOF

Sumo__help_1000BASE-T() {
cat << EOF
 $(tput smul)Help sheet Ethernet 1000BASE-T $(tput rmul)
 
 Speed: 1000 MBit/s or 125000 Ko/s or 125 Mo/s 
  
 Gigabit Ethernet (GbE) over twisted-pair wiring (T standards for Twisted Pairs)
 It can be operated in full duplex (-FD) or half duplex mode (-HD).
 GbE is defined in standard IEEE 802.3ab. 
  
 More infos: https://en.wikipedia.org/wiki/Gigabit_Ethernet
 Other Ethernet standards:  https://en.wikipedia.org/wiki/IEEE_802.3
EOF
}

Sumo__help_wifi() {
cat << EOF
 $(tput smul)Help sheet WIFI $(tput rmul)
 
 Generation    IEEE Standard     Date      Mbits/s       Radio Freq. (GHz)
 Wi-Fi 0	      802.11            1997      1-2           2.4
 Wi-Fi 1	      802.11b           1999      1-11          2.4
 Wi-Fi 2	      802.11a           1999 	    6-54          5
 Wi-Fi 3	      802.11g           2003 	    6-54          2.4
 Wi-Fi 4       802.11n           2009 	    6.5-600       2.4, 5
 Wi-Fi 5       802.11ac          2013 	    6.5-6933      5
 Wi-Fi 6       802.11ax          2021 	    0.4-9608      2.4, 5
 Wi-Fi 6E      802.11ax          2021 	    0.4-9608      2.4, 5
 Wi-Fi 7       802.11be          2024 	    0.4-23059     2.4, 5, 6
 Wi-Fi 8       802.11bn          2028 	    100 000       2.4, 5, 6 
EOF
}

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
# Release file path: sumo__options.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-07 20:31:13.800021271 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file contains the definition of all options supported by SUMO.
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

# Keys are option alternatives separated by |
declare -A SUMO__OPTION_LIST_SDESC # Option short description 
declare -A SUMO__OPTION_LIST_DESC # Option description
declare -A SUMO__OPTION_LIST_ARGS # Tells whether arg expected or none
declare -A SUMO__OPTION_LIST_ARGS_TYPE # Give the type of the argument(s)
declare -A SUMO__OPTION_LIST_VALS # Executed code when processing an expected arg
declare -A SUMO__OPTION_LIST_ACTI # Executed code when option is detected
declare -A SUMO__OPTION_LIST_INTERN # Tells whether the option is not intended for end-users or only for advanced ones

# arg 1: 1=no value expected, 0 value expected

SUMO__OPTION_LIST_INTERN["--debug-mode"]=0
SUMO__OPTION_LIST_SDESC["--debug-mode"]="Activates debug logs"
SUMO__OPTION_LIST_DESC["--debug-mode"]="
Show the debug logs. This may only be used for bug tracking purposes.
"
SUMO__OPTION_LIST_ARGS["--debug-mode"]="1"
SUMO__OPTION_LIST_ACTI["--debug-mode"]='__LOG_DEBUG__=0'

SUMO__OPTION_LIST_SDESC["--refresh-deps"]="Refreshes installation of dependency packages"
SUMO__OPTION_LIST_DESC["--refresh-deps"]="
Refreshes installation of dependency packages. 
When no dependency name is specified following the option, only the relevant dependencies are installed on demand depending on the used functionality.
If an explicit dependency name is specified, then the script will attempt to reinstall the matching dependencies immediately at startup.
Supported predefined dependency names are : "all", "smb", "vera", "luks", "qemu", "google-drive-ocamlfuse".
Otherwise, it will be attempted to install a Debian package of the specified name.

Note that for specific mounts like with google-drive-ocamlfuse, this may imply a more complex process that just a system package reinstallation,
whereby actions from the users may be required.
"
SUMO__OPTION_LIST_ARGS["--refresh-deps"]="2"
SUMO__OPTION_LIST_ARGS_TYPE["--refresh-deps"]="smb, luks, vera, qemu, sshfs, google-drive-ocamlfuse, all, <<apt package>>"
SUMO__OPTION_LIST_ACTI["--refresh-deps"]='__REFRESH_DEPS__=0'
SUMO__OPTION_LIST_VALS["--refresh-deps"]='SUMO__VARS["REFRESH_DEPS"]="${__myarg}"'


SUMO__OPTION_LIST_SDESC["-s|--silent"]="Less messages on stdout"
SUMO__OPTION_LIST_DESC["-s|--silent"]="
Do not show the device mounting details after successful mounting/unmounting.
"
SUMO__OPTION_LIST_ARGS["-s|--silent"]="1"
SUMO__OPTION_LIST_ACTI["-s|--silent"]='SUMO__VARS["SILENT"]=0'

SUMO__OPTION_LIST_SDESC["-n|--no-headers"]="Hide headers and formatting frames"
SUMO__OPTION_LIST_DESC["-n|--no-headers"]="
Do not display headers nor any additional formatting frames.
"
SUMO__OPTION_LIST_ARGS["-n|--no-headers"]="1"
SUMO__OPTION_LIST_ACTI["-n|--no-headers"]='SUMO__VARS["NO_HEADER"]=0'

SUMO__OPTION_LIST_SDESC["-p|--password"]="Password/passphrase to use when data source requests it"
SUMO__OPTION_LIST_DESC["-p|--password"]="
Enables automated input of password/passphrase when data source requests it,
like VERA, LUKS, SSH etc. 
Be careful not passing the passphrase directly in clear text on command line. 
Ignored if disk is not encrypted
"
SUMO__OPTION_LIST_ARGS["-p|--password"]="0"
SUMO__OPTION_LIST_ARGS_TYPE["-p|--password"]="STRING"
SUMO__OPTION_LIST_ACTI["-p|--password"]=""
SUMO__OPTION_LIST_VALS["-p|--password"]='SUMO__VARS["PASSPHRASE"]="$__myarg"'


SUMO__OPTION_LIST_SDESC["-i|--interactive"]="runs in interactive mode (dashboard)"
SUMO__OPTION_LIST_DESC["-i|--interactive"]="
Runs the dashboard showing the list of devices and mounted data sources as interative menu,
where actions can be performed on the selected item, e.g. mounting/unmounting
by with <enter>
"
SUMO__OPTION_LIST_ARGS["-i|--interactive"]="1" # deactivated arg at the moment
SUMO__OPTION_LIST_ARGS_TYPE["-i|--interactive"]="FILTER[,FILTER...]"
SUMO__OPTION_LIST_ACTI["-i|--interactive"]='SUMO__VARS["INTERACTIVE"]=0'


SUMO__OPTION_LIST_SDESC["-y"]="Assume 'Yes' when prompted for confirmation"
SUMO__OPTION_LIST_DESC["-y"]="
Assume 'Yes' answer for any confirmation request
"
SUMO__OPTION_LIST_ARGS["-y"]="1"
SUMO__OPTION_LIST_ACTI["-y"]='Input__pushForcedInput "y"'


SUMO__OPTION_LIST_SDESC["-f|--force"]="Assume 'Yes' when -y is not applicable"
SUMO__OPTION_LIST_DESC["-f|--force"]="
Force proceeding for cases where -y is not operating.
"
SUMO__OPTION_LIST_ARGS["-f|--force"]="1"
SUMO__OPTION_LIST_ACTI["-f|--force"]='SUMO__VARS["FORCED"]=0'



SUMO__OPTION_LIST_SDESC["--lazy"]="Perform a lazy mount"
SUMO__OPTION_LIST_DESC["--lazy"]="
Proceed with a lazy unmount.
"
SUMO__OPTION_LIST_ARGS["--lazy"]="1"
SUMO__OPTION_LIST_ACTI["--lazy"]='SUMO__VARS["LAZY"]="lazy"'



SUMO__OPTION_LIST_SDESC["--log"]="Show the log tail"
SUMO__OPTION_LIST_DESC["--log"]="
Show the log tail.
"
SUMO__OPTION_LIST_ARGS["--log"]="2"
SUMO__OPTION_LIST_ACTI["--log"]='
local __log
_getLogPath __log
tail -F "${__log}" -n 40
_quit ""
'
SUMO__OPTION_LIST_VALS["--log"]='
local __log
_getLogPath __log
tail -F "${__log}" -n "${__myarg}"
_quit ""
'


SUMO__OPTION_LIST_SDESC["--files"]="Lists all the files used by the app (config, log etc)"
SUMO__OPTION_LIST_DESC["--files"]="
Lists the files used by the app, i.e. configuration file, log file(s), active history file, any cache file
"
SUMO__OPTION_LIST_ARGS["--files"]="1"
SUMO__OPTION_LIST_ACTI["--files"]='
#echo -n "Configuration: "
local file
if _getConfigFilePath file ; then
        echo "${file}"
fi

if _getRecentListFilePath file ; then
        echo "${file}"
fi

#echo -n "Package dependencies cache: "
if _getDependenciesCacheFile file ; then
        echo "${file}"
fi

if _getLogPath file ; then
        echo "${file}"
fi

_quit ""
'


SUMO__OPTION_LIST_SDESC["-u"]="Unmounts the specified data source or mountpoint folder"
SUMO__OPTION_LIST_DESC["-u"]="
Tries to unmounts the specified device, which can be a block device path, a disk filename or a label.
"
SUMO__OPTION_LIST_ARGS["-u"]="1" 
SUMO__OPTION_LIST_ACTI["-u"]='SUMO__VARS["DO_UNMOUNT"]=0'


SUMO__OPTION_LIST_SDESC["--display-format"]="Shows the list in the specified format (bolddisk,color,bgcolor)"
SUMO__OPTION_LIST_DESC["--display-format"]="
Select a display format among the following:

- 'bolddisk': the line corresponding to actual disks are displayed in bold

- 'bgcolor': disks and related sub items like partitions are shown with a specific background color

- 'color': disks and related sub items like partitions are shown with a specific font color
"
SUMO__OPTION_LIST_ARGS["--display-format"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["--display-format"]="bolddisk | color | bgcolor"
SUMO__OPTION_LIST_ACTI["--display-format"]=""
SUMO__OPTION_LIST_VALS["--display-format"]='
        SUMO__VARS["DISPLAY_FORMAT"]="${__myarg}" 
        case "${__myarg}" in
                bgcolor) Term__useListLinesColors=0 ; Term__listLinesColorCounter=10 ;;
                color) Term__useListLinesColors=0 ; Term__listLinesColorCounter=0 ;;
                bolddisk) Term__useListLinesColors=0;;
                *) _susage "Invalid display format '${__myarg}' specified." ;;
        esac        
'


SUMO__OPTION_LIST_SDESC["-L|--label"]="Label to use for selecting data source to mount/unmount"
SUMO__OPTION_LIST_DESC["-L|--label"]="
A logical name associated with the disk. It is often a convenient way to address 
the device regardless of the actual mount location or device path. 
The label shall be no longer than 16 chars. This is due a limitation on some 
systems (like unix)

For Vera volumes, only integer values are accepted. By extension, if the label
 specified for any operation is an integer number, a Vera disk is assumed.
"
SUMO__OPTION_LIST_ARGS["-L|--label"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-L|--label"]="STRING"
SUMO__OPTION_LIST_ACTI["-L|--label"]=""
SUMO__OPTION_LIST_VALS["-L|--label"]='SUMO__VARS["FS_LABEL"]="$__myarg"'




SUMO__OPTION_LIST_SDESC["--volume-name"]="The name for an encrypted volume"
SUMO__OPTION_LIST_DESC["--volume-name"]="
By default, the file base name is used as volume name for encrypted files like LUKS.
This option enables to specify an alternative names, which can be useful when a previous mount
could not be ended properly, which may make the previous volume name unusable.
"
SUMO__OPTION_LIST_ARGS["--volume-name"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["--volume-name"]="STRING"
SUMO__OPTION_LIST_ACTI["--volume-name"]=""
SUMO__OPTION_LIST_VALS["--volume-name"]='SUMO__VARS["VOLUME_NAME"]="$__myarg"'




SUMO__OPTION_LIST_SDESC["-l|--list"]="List all available devices and data sources"
SUMO__OPTION_LIST_DESC["-l|--list"]="
By default, lists all available devices and data sources along with their mounting status and other information.

The list can be filtered or enhanced with a coma-separated list of keywords. Possible filters:

- all: Display absolutely all data sources, including loop devices.

- free: Only show not mounted data sources

- <BLK_TYPE>: Only list data sources of the specified type of block device. It's a device type as returned by 'lsblk'. E.g.: 'disk', 'loop'. 

- <FS_TYPE> : Only list data sources of the specified type of file system. It's a file system type as returned by 'blkid --list-filesystems'. E.g. 'ntfs', 'ext4'. 

- <SEARCH STRING>: Do list those data sources which file system type or source location contains the specified string. Note the string is searched only after its has been searched for a block type or FS type matching exactly that string

- no<__filter name__> :Excludes data sources that would have been selected using the specified filter name. E.g. 'noloop' excludes all loop devices, 'nodisk' excludes all disks.

By default, the loop devices are not displayed. This behavior is programmed in the configuration file.

The -n, --display-format options enable to control look&feel of the list.
"
SUMO__OPTION_LIST_ARGS["-l|--list"]="2" 
SUMO__OPTION_LIST_ARGS_TYPE["-l|--list"]="FILTER[,FILTER...]"
SUMO__OPTION_LIST_ACTI["-l|--list"]='SUMO__VARS["LIST"]=0'
SUMO__OPTION_LIST_VALS["-l|--list"]='
        if Str__startsWith "${__myarg}" "-" ; then
                __myprevarg="${__myarg}"  # handle any option argument in next turn
        elif [ -e "${__myarg}" ] ; then
                local localPrevArg
                Sumo__processDashLessArg "${__myarg}" localPrevArg $_arg_cnt # handle it as file or device
                _arg_cnt=$?
                __myprevarg=$localPrevArg
        else
                SUMO__VARS["LIST"]=0
                # DEVTYPE is also used to store the whole options string for listing
                SUMO__VARS["DEVTYPE"]="${__myarg}" 
                # Read individual options
                local filterFields=()
                local filter=""
                local i=0
                readarray -t -d',' filterFields <<< "${__myarg}"
                while [ $i -lt ${#filterFields[@]} ]
                do
                        local filter="${filterFields[$i]}"
                        #Str__toUpper filter
                        Str__trimEnd "$filter" filter

                        # If there is any filter which is not an exclusion,
                        # we disable history: not shown and not updated 
                        if ! Str__startsWith $filter "no" ; then
                                SUMO__VARS["DISABLE_HISTORY"]=true
                                #_log_dbg "DISABLE_HISTORY !!!!!!!!!!!!!"
                        fi
                        # This is not used anymore
                        #local cmd="SUMO__VARS[\"LIST_OPT_${filter}\"]=0"
                        #eval "$cmd"
                        #echo "CMD=$cmd"
                        i=$(($i+1))
                done                
        fi
'

SUMO__OPTION_LIST_SDESC["-F|--format-disk"]="Format a block device as a disk"
SUMO__OPTION_LIST_DESC["-F|--format-disk"]="
This option enables to format the input block device as a single-partition disk on which is installed the 
file system given as argument to this option. 

Formatting the device will result in the total loss of any data stored previously on the block device.
This option has not effect if a network device is specified. 

The format function is not available and shall not be used from plain command line. This option is used when sumo is called from the dashboard, whereby it also passes the --caller option.
"
SUMO__OPTION_LIST_ARGS["-F|--format-disk"]="1" 
SUMO__OPTION_LIST_ACTI["-F|--format-disk"]='SUMO__VARS["FORMAT_DISK"]=true'
SUMO__OPTION_LIST_VALS["-F|--format-disk"]=''



SUMO__OPTION_LIST_SDESC["-B|--flash-disk"]="Flashes a disk image to a device"
SUMO__OPTION_LIST_DESC["-B|--flash-disk"]="
Flashes a disk image the specific devce using the 'dd' utility. Typically, the disk image can be a raw image (.img) 
or an ISO image.

Most live CD images are hybrid ISO and so this function is also suitable to create bootable images without
requiring an external tool.
If the ISO is not hybrid, it can be made so using the "isohybrid" command (sudo apt install syslinux-utils)

Flashing a disk image will result in the total loss of any data stored previously on the device.
This option has no effect if a network device is specified. 
"
SUMO__OPTION_LIST_ARGS["-B|--flash-disk"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-B|--flash-disk"]="FILENAME"
SUMO__OPTION_LIST_ACTI["-B|--flash-disk"]=''
SUMO__OPTION_LIST_VALS["-B|--flash-disk"]='
SUMO__VARS["FLASH_DISK"]="$__myarg"
'




SUMO__OPTION_LIST_SDESC["-P|--part-disk"]="Partition a disk."
SUMO__OPTION_LIST_DESC["-P|--part-disk"]="
Partition a disk. At the moment, it is only possible to create a single partition occupying whole disk.

The following types of partitions are also excluded:

- Linux root * 

- Linux user *

- Verity root *

- Verity user *

- Verity root signature *

For advanced users, use any of the following: fdisk, sfdisk, gdisk, sgdisk. 
Note fdisk and gdisk are deemed for interactive operations.
"
SUMO__OPTION_LIST_ARGS["-P|--part-disk"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-P|--part-disk"]="PART_TYPE_UUID"
SUMO__OPTION_LIST_ACTI["-P|--part-disk"]=''
SUMO__OPTION_LIST_VALS["-P|--part-disk"]='
SUMO__VARS["PART_DISK"]="$__myarg"
'




SUMO__OPTION_LIST_SDESC["-t|--fs-type"]="File system to install when creating a new disk file"
SUMO__OPTION_LIST_DESC["-t|--fs-type"]="
File system type when a new disk file system is created by default, it is ext4.
"
SUMO__OPTION_LIST_ARGS["-t|--fs-type"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-t|--fs-type"]="STRING"
SUMO__OPTION_LIST_ACTI["-t|--fs-type"]=""
SUMO__OPTION_LIST_VALS["-t|--fs-type"]='SUMO__VARS["FS_TYPE"]="$__myarg"'


SUMO__OPTION_LIST_SDESC["-o|--options"]='Mount options for the low-level backend mount tools'
SUMO__OPTION_LIST_DESC["-o|--options"]='
This option enables to forward mount options to the low-level mount tools.

In the context of disk creation, the option value "size=<disk size>" enables 
to predefine the size of the disk to create without having to enter it manually 
when prompted. <disk size> shall be given as an integer followed 
by any of K,M,G,T resp. KiB, MiB, GiB, TiB.
'
SUMO__OPTION_LIST_ARGS["-o|--options"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-o|--options"]="OPTION=STRING[,OPTION=STRING...]"
SUMO__OPTION_LIST_ACTI["-o|--options"]=""
SUMO__OPTION_LIST_VALS["-o|--options"]='Sumo__readCreationParameters "${__myarg}"'

SUMO__OPTION_LIST_INTERN["--test"]=0
SUMO__OPTION_LIST_SDESC["--test"]="Executes all the self-tests."
SUMO__OPTION_LIST_DESC["--test"]="
Executes all the self-tests. When test name is supplied, only this test is run.
"
SUMO__OPTION_LIST_ARGS["--test"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["--test"]="TESTNAME"
SUMO__OPTION_LIST_ACTI["--test"]='SUMO__VARS["RUN_TESTS"]=0'
SUMO__OPTION_LIST_VALS["--test"]='SUMO__VARS["TEST_NAME"]="${__myarg}"'

SUMO__OPTION_LIST_SDESC["--windows"]="Shows free Windows partition(s)"
SUMO__OPTION_LIST_DESC["--windows"]="
Shows free Windows partition(s).
This option is equilavent to : 
  sumo -n -l noloop,ntfs,free
"
SUMO__OPTION_LIST_ARGS["--windows"]="1" 
SUMO__OPTION_LIST_ACTI["--windows"]='
        SUMO__VARS["NO_HEADER"]=0
        SUMO__VARS["LIST"]=0
        SUMO__VARS["DEVTYPE"]='noloop,ntfs'
        SUMO__VARS["INTERACTIVE"]=0
        #SUMO__VARS["LOOKUP_MNT_WINDOWS"]=0
        #availWindows="$(sumo -n -l noloop,ntfs,free)"
        #echo "$availWindows"
        #echo
        #Input__cursorSelect "$availWindows" "Select folder to mount or unmount" 1
'
SUMO__OPTION_LIST_VALS["--windows"]=''


SUMO__OPTION_LIST_INTERN["--caller"]=0
SUMO__OPTION_LIST_DESC["--caller"]='
Enables to pass on the information of the process which invoked this program.
Typically, it can be its PID.
'
SUMO__OPTION_LIST_ARGS["--caller"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["--caller"]="PID"
SUMO__OPTION_LIST_ACTI["--caller"]=""
SUMO__OPTION_LIST_VALS["--caller"]='
SUMO__VARS["CALLER"]="${__myarg}"
'

SUMO__OPTION_LIST_SDESC["-a|--all"]="Unmounts all contained partitions and nested data sources"
SUMO__OPTION_LIST_DESC["-a|--all"]="
When unmounting a data source requires to unmount multiple child data sources, 
or if the data source is mounted multiple time, specifying this option allows to proceed to the unmounting of all of them. 
"
SUMO__OPTION_LIST_ARGS["-a|--all"]="1" 
SUMO__OPTION_LIST_ACTI["-a|--all"]='SUMO__VARS["ALL_FLAG"]=0'
SUMO__OPTION_LIST_VALS["-a|--all"]=""


SUMO__OPTION_LIST_SDESC["-H|--history"]="Use history of the specified name"
SUMO__OPTION_LIST_DESC["-H|--history"]="
Tells sumo to use the history of the specified name. The matching history file is expected to be named 
recent.yml.<history name> located in ~/.config/Sumo folder.

The previous history recent.yml is renamed to recent.yml.old or recent.yml.CURRENT_HISTORY_SAVE_NAME 
if CURRENT_HISTORY_SAVE_NAME is specified

Without argument, this option lists the names of the available histories.
"
SUMO__OPTION_LIST_ARGS["-H|--history"]="2" 
SUMO__OPTION_LIST_ARGS_TYPE["-H|--history"]="HISTORY_NAME[:CURRENT_HISTORY_SAVE_NAME]"
SUMO__OPTION_LIST_ACTI["-H|--history"]='SUMO__VARS["HISTORY_NAME"]="@@@"'
SUMO__OPTION_LIST_VALS["-H|--history"]='
SUMO__VARS["HISTORY_NAME"]="$__myarg"
'


SUMO__OPTION_LIST_SDESC["--ghost"]="Do not record any history"
SUMO__OPTION_LIST_DESC["--ghost"]="
With this option, the history file is not updated. The history is still shown on the dashboard, but there won't be any trace
of the mount operations in the history file.
"
SUMO__OPTION_LIST_ARGS["--ghost"]="1" 
SUMO__OPTION_LIST_ACTI["--ghost"]='SUMO__VARS["HISTORY_GHOST"]=true'



SUMO__OPTION_LIST_SDESC["-M|--monitoring-time"]="Timeout for refreshing list in dashboard"
SUMO__OPTION_LIST_DESC["-M|--monitoring-time"]="
The monitoring timeout for refreshing the dashboard.
"
SUMO__OPTION_LIST_ARGS["-M|--monitoring-time"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-M|--monitoring-time"]="SECONDS"
SUMO__OPTION_LIST_ACTI["-M|--monitoring-time"]='SUMO__VARS["MONITORING_TIME"]=0'
SUMO__OPTION_LIST_VALS["-M|--monitoring-time"]='SUMO__VARS["MONITORING_TIME"]="${__myarg}"'


SUMO__OPTION_LIST_SDESC["-U|--user"]="User name to use when data source requests it"
SUMO__OPTION_LIST_DESC["-U|--user"]="
Enables automated input of use name when data source requests it, like VERA, LUKS, SSH etc. 
"
SUMO__OPTION_LIST_ARGS["-U|--user"]="0" 
SUMO__OPTION_LIST_ARGS_TYPE["-U|--user"]="STRING"
SUMO__OPTION_LIST_ACTI["-U|--user"]=""
SUMO__OPTION_LIST_VALS["-U|--user"]='SUMO__VARS["NET_LOGIN"]="${__myarg}"'

SUMO__VARS["MOUNT_OPTIONS"]=""



<<'EOF'
TEMPLATE!
SUMO__OPTION_LIST_SDESC[""]=""
SUMO__OPTION_LIST_DESC[""]=""   
SUMO__OPTION_LIST_ARGS_TYPE[""]=""
SUMO__OPTION_LIST_ARGS["0 1 2"]=""      # 0:mandatory value, 1:no value, 2:optional value
SUMO__OPTION_LIST_ACTI[""]=""           # Action to be executed when option is read
SUMO__OPTION_LIST_VALS[""]=''           # Action to be executed when option accepts a value
EOF

:<<'EOF'
# check if useful
                -D|--device-type)
                        prevarg="${__myarg}"
                ;;
                -m|--image-type)
                        prevarg="${__myarg}"
                ;;
 -m,--image-type        
        explicit block device type for disk creation e.g. 'luks' or 'img'. Disk file 
        extension will be enforced to match the value specified. Supported values: 
        ${SUMO__VARS["ALLIMAGETYPES"]}


EOF


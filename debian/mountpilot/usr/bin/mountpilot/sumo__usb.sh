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
# Release file path: sumo__usb.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-08 14:11:40.668266682 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to mounting/unmounting over USB link
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

# https://developer.android.com/tools/adb

:<<'EOF'
Tells whether the passed argument looks like a USB adb URL, i.e.
of the basic form adb://usb
@param [1] URL
EOF

USB__isAdbURL()
{
    if [ $# -eq 1 ] ; then
        [[ "$1" =~ ^adb:\/\/usb$ ]]
    else
        _log_warn "${FUNCNAME[0]}: invalid argument count. Expected 1 argument."
        return -1
    fi
}


:<<'EOF'
Attempts to decode adb URL for passed string.
Upon success return 0 and sets out_protocol to 'adb'
adb://usb
@param [1] USB URL
EOF

USB__decodeAdbURL()
{
    local url="$1"
    local -n out_protocol=$2

    if ! Args__checkCount "${FUNCNAME[0]}" 2 "$#" ; then return -1 ; fi

    if ! USB__isAdbURL "$url" ; then 
        _log_warn "${FUNCNAME[0]}: invalid USB URL '$url'."
        return 1
    fi

    Str__trim "$url" url
    Str__trimEnd "$url" url "/"

    out_protocol="$url"
    Str__toTail out_protocol "adb://" last
    Str__toLower out_protocol
    [ "${out_protocol}" = "adb" ]
}

:<<'EOF'
Sets up internal network infos from the URL: host, user, share, password, path
EOF
Sumo__usb_setConnectionsInfosFromFileURL() {
        local proto="";
        local usbRef="$1"
        Str__trim "$usbRef" usbRef
        Str__trimEnd "$usbRef" usbRef "/"

        if USB__isAdbURL "$usbRef" ; then
                _log_dbg "ADB FOUND!"
                # share contains the port number
                USB__decodeAdbURL "$usbRef" proto

                SUMO__VARS["NET_PROTO"]="adb"
                SUMO__VARS["DEVPART"]="adbfs"
        else
                _susage "Invalid URL '$usbRef'."
        fi        

        SUMO__VARS["DEVMAPPER"]="${SUMO__VARS["DEVPART"]}"
        _log_dbg "proto:$proto"
}

:<<'EOF'
Retrieves the mounting infos according to the internallly stored mount point
and UNC/SSH login, and sets up the internal network infos from the URL.

Exits the app when requesting to mount on a folder already mounted.
EOF

#findmnt
# ├─/home/michel/mnt/android            adbfs                     fuse.adbfs  rw,nosuid,nodev,relatime,user_id=1000,group_id=1000,allow_other

Sumo__usb_resolveConnectionsInfos() {
        _log_dbg Sumo__usb_resolveConnectionsInfos

        if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] ; then 
                local foundSource="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"

                if [ -z "$foundSource" ] ; then
                        # If a mount folder is specified, resolve the device path and its parent.
                        if Dev__findMountSource "${SUMO__VARS["MOUNT_POINT"]}" foundSource ; then
                                SUMO__VARS["MOUNTED"]=0
                        fi
                fi

                if [ ! -z "$foundSource" ] ; then
                        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then # unmounting case
                                SUMO__VARS["DEVPART"]="$foundSource"
                                SUMO__VARS["DEVMAPPER"]="${SUMO__VARS["DEVPART"]}"
                                return 0
                        #else
                        #        _quit "Folder ${SUMO__VARS["MOUNT_POINT"]} is already mounted from '$foundSource'."
                        fi
                else
                        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] ; then
                                return 1
                        fi
                fi
        fi
        local netRef
        if [ -z "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ] ; then
                netRef="${SUMO__VARS["IMG_FILE"]}"
        else
                netRef="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
        fi

        if [ "${netRef}" == "adbfs" ] ; then
            Sumo__usb_setConnectionsInfosFromFileURL "adb://usb" # This shall set SUMO__VARS["DEVPART"]
        else
            Sumo__usb_setConnectionsInfosFromFileURL "${netRef}" # This shall set SUMO__VARS["DEVPART"]
        fi
        Sumo__resolveMountingInfos "${SUMO__VARS["DEVPART"]}"
        return 0
}

:<<'EOF'
Initializes the USB from the URL stored in SUMO__VARS["IMG_FILE"]}:
It also loads the matching required dependencies according to the type of address used.
The return result is buffered in SUMO__VARS["IMG_FILE_IS_URL"] which is used as reference 
if the function is called again.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__usb_init()
{
        if [ -v SUMO__VARS["IMG_FILE_IS_URL"] ] ; then
                return ${SUMO__VARS["IMG_FILE_IS_URL"]}
        else        
                SUMO__VARS["IMG_FILE_IS_URL"]=0  # assume it is ok and actually set below
        fi

        local usbRef="${SUMO__VARS["IMG_FILE"]}"
        if [ -z "$usbRef" ] ; then
            usbRef="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
        fi

        Str__trim "$usbRef" usbRef
        Str__trimEnd "$usbRef" usbRef "/"

        if [ "$usbRef" = "adbfs" ] || USB__isAdbURL "$usbRef" ; then
                _loadDep "adb"
                if [ ! -v SHELL_API_DEP_LOADED["adb"] ] && [ ! -v SHELL_API_DEP_LOADED["google-android-platform-tools-installer"] ]  ; then
                        _exit -1 "Sorry, the package(s) to support adb could not be installed. Android debug link is not supported."
                fi

                local devices 
                local resSelect
                Sumo__adb_selectDevice devices true false
                resSelect=$?
                if [ $resSelect -ne 0 ] ; then
                        # A returned value of 2 means the device is not authorized
                        # or has an invalid status. Not relevant to perform an unmount
                        if [ $resSelect -ne 2 ] ; then
                                # IF adb is not accessible, do however not forbid to try to unmount it
                                if [ ${SUMO__VARS["DO_UNMOUNT"]} -ne 0 ] ; then
                                        _log_high "Attempting an unmount of '${usbRef}' to cleanup lost mount, if necessary"
                                        $0 -s -u "${usbRef}" 
                                        if ! Sumo__adb_selectDevice devices true true ; then
                                          SUMO__VARS["IMG_FILE_IS_URL"]=1
                                        fi
                                fi
                        else
                                SUMO__VARS["IMG_FILE_IS_URL"]=1
                        fi
                fi
                SUMO__VARS["ADB_DEVICE"]="$devices"
        else
                # No error message, lets main loop go forward
                SUMO__VARS["IMG_FILE_IS_URL"]=1
        fi

        return ${SUMO__VARS["IMG_FILE_IS_URL"]}
}

Sumo__usb_getDataSourceRef()
{
        local originalSrc="$1"
        local -n convertedSrc="$2"
        if [ "${SUMO__VARS["NET_PROTO"]}" = "adb" ] ; then                
                convertedSrc="adb://usb"
        else
                convertedSrc="${SUMO__VARS["DEVPART"]}"
        fi
}

:<<'EOF'
Tests whether the passed argument is valid USB address. 
Unless Sumo__usb_isValidAddress, this function does not alter internal variables. 
@param [1] an explicit network address.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__usb_isArgValidAddress()
{
        local usbRef="$1"
        Str__trim "$usbRef" usbRef 
        Str__trimEnd "$usbRef" usbRef "/"

        if USB__isAdbURL "$usbRef" || [ "$usbRef" = "adbfs" ]; then
                return 0
        else
                return 1
        fi
}

:<<'EOF'
Main function for handling network-based mounting/unmounting, e.g. over SMB or sSH
EOF

Sumo__usb()
{
        _log_dbg "Sumo__usb"
        local usbRef=""
        #_log "Sumo__usb '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}'"

        if ! Sumo__usb_isArgValidAddress "${SUMO__VARS["IMG_FILE"]}" || ([ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] && [ ! -z "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ]); then
                #_log_dbg "Sumo__usb ! Sumo__usb_isArgValidAddress IMG_FILE=${SUMO__VARS["IMG_FILE"]}, '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                if Sumo__usb_isArgValidAddress "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ; then
                        if USB__isAdbURL "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ; then
                                Sumo__usb_setConnectionsInfosFromFileURL "${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                                Sumo__resolveMountingInfos "${SUMO__VARS["DEVPART"]}"
                        else
                                usbRef="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                                SUMO__VARS["DEVPART"]="${usbRef}"
                                if [ "$usbRef" = "adbfs" ] ; then
                                    SUMO__VARS["NET_PROTO"]="adb"
                                else
                                    _log_err "Unsupported USB mount source '${usbRef}' (internal error?)"
                                    return 1                            
                                fi
                        fi
                else
                        #_log_dbg "Sumo__usb ! Sumo__usb_isArgValidAddress"
                        return 1
                fi
        else
                #_log_dbg "Sumo__usb ELSE Sumo__usb_isArgValidAddress  IMG_FILE:'${SUMO__VARS["IMG_FILE"]}' '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                usbRef="${SUMO__VARS["IMG_FILE"]}"
                Str__trim "$usbRef" usbRef
                Str__trimEnd "$usbRef" usbRef "/"
                SUMO__VARS["IMG_FILE"]="$usbRef"

                if ! Sumo__usb_resolveConnectionsInfos ; then
                        _exit -6 "Failed to resolve mount source." 
                fi
        fi

        #_log "Sumo__usb   IMG_FILE:'${SUMO__VARS["IMG_FILE"]}' '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"

        if Sumo__usb_init ; then
            # Handle unmounting requests
            local ret
            if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
                    Sumo__usb_unmount
                    ret=$?
            else
                    Sumo__usb_determineMountPoint
                    Sumo__usb_mount
                    ret=$?
            fi
        else
            ret=1
        fi

        _exit $ret ""
}

:<<'EOF'
Function used to determine or let user enter the mountpoint and the name of the share if address is SMB or UNC
EOF

Sumo__usb_determineMountPoint()
{
        if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] && [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                Sumo__manageValidMountpointSetting Sumo__usb_getMountpoint "${SUMO__VARS["MOUNT_POINT"]}"
        elif USB__isAdbURL "${SUMO__VARS["IMG_FILE"]}" ; then
                Sumo__manageValidMountpointSetting Sumo__usb_getMountpoint
        else                
                _exit -55 "Internal error: unhandled network URL. Please report the bug." # We should never arrive here since tested beforehand
        fi
}

:<<'EOF'
Call back function used when searching for a unique mount point path. It is called
by Sumo__manageValidMountpointSetting for setting the default proposed mount point.

If it already exists (and mounted from something else), this callback is called to 
propose an new path based on an incrementing counter which is passed on as argument.

@param [1] Counter for setting a unique mount point path
@param [2] output proposed mount point path
EOF

Sumo__usb_getMountpoint()
{
        local cnt=$1
        local -n out_default_mp=$2

        if [ "${SUMO__VARS["NET_PROTO"]}" = "adb" ] ; then
            if Sumo__adb_selectDevice out_default_mp false false; then
                if [ $cnt -gt 0 ] ; then
                        out_default_mp="${out_default_mp}:$cnt"
                fi
                return 0        
            else
                return 1
            fi
        else 
            return 1
        fi
}

#    - execute 'killall -9 adb' (kills the adb server which communicates with the device)
Sumo__adb_help="Perform some checks:
    - USB cable is connected
    - 'User developper options' are activated on the Android device
       Note: this achieved by tapping 7 times on 'build number' inside 'Settings/About'
       Note: 'User developper options' are accessed via 'Settings/System' afterwards
    - 'USB debugging' mode is activated inside 'User developper options'
    - USB preferences are either set to 'PTP' or 'No data transfer' (Settings/Connected devices/USB).
    - Connection to the device was accepted when asked so on the device.

Follow these instructions if it is still now working:
    - (try first without Plug in/off the cable)
    - Deactivate 'USB debugging', 
    - Revoke USB auth, 
    - Activate 'USB debugging' again, 
    - Unmount any auto-mount done by the system
    - accept authorization when asked so. 
    - Ensure 'PTP' or 'No data transfer' transfer is selected
      when asked so on the device.
    - Sometimes you might have to try the above twice.

Sometimes, it may take up to 1 or 2 minutes for the first operation to complete. 
It is often worth to wait a little bit instead of breaking the connection and 
reach an unstable or stuck system state.

If it still fails despite that all, then either the device is too old to be compatible 
with the installed adbfs package, or the adbfs package needs to be upgraded.
"    

Sumo__adb_selectDevice()
{
    #_log_dbg "Sumo__adb_selectDevice"
    local -n __out_adbdevice=$1
    local onlyTest=$2
    local silent=$3

    local adbdevices=""
    if $onlyTest ; then
        #_log_dbg "Sumo__adb_selectDevice onlyTest"
        local adbdevices=()
        local adbdevicesUnauth=()
        local _adbdevicesUnauthStatus=()

        Adb__listDevices adbdevices adbdevicesUnauth _adbdevicesUnauthStatus
        #adbdevices="" # test: simulate an error, also remove ! line 176
        if [ ${#adbdevices[@]} -eq 0 ] ; then
                if ! $silent ; then

                        if [ ${#adbdevicesUnauth[@]} -eq 0 ] ; then
                                if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] ; then
                                        _log_warn "no adb device detected ('adb devices' returned no devices)."
                                        _log_warn "attempting to unmount anyway"
                                else
                                        _log_err "no adb device detected ('adb devices' returned no devices)."
                                        echo "Please $Sumo__adb_help" >&2
                                fi
                                return 1
                        else
                                if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] ; then
                                        _log_warn "adb device cannot be unmounted (unauthorized?)."
                                else
                                        _log_err "adb device cannot be mounted (unauthorized?)."
                                fi
                                return 2
                        fi
                fi

                return 1
        else
                if [ ${#adbdevices[@]} -gt 1 ] ; then
                        local msg
                        msg="
There are more than one device connected:

${adbdevices[@]}

adb over USB does only work with a single connection. 

Please disconnect the unused device(s).
"
                        #_log_err ""
                        _exit -51 "$msg"
                fi
        fi

        #_log_dbg "Sumo__adb_selectDevice checkReponsiveness"

        local checkReponsiveness=""
        local timeout=3
        checkReponsiveness=$(timeout -k 0 -s SIGKILL $timeout adb shell ls)
        if [ $? -ne 0 ] ; then
            #killall -9 adb
            if ! $silent ; then
                if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] ; then
                    _log_warn "adb device(s) was detected (adbdevices), but device did not respond within ${timeout}s ('adb shell ls')."
                    _log_warn "attempting to unmount anyway"
                else
                    _log_err "adb device(s) was detected (adbdevices), but device did not respond within ${timeout}s ('adb shell ls')."
                    echo "To solve this, wait 1/2 minute before retry and " >&2
                    echo "$Sumo__adb_help" >&2
                fi
            fi
            return 1
        fi
        #_log_dbg "Sumo__adb_selectDevice checkReponsiveness passed!"
        __out_adbdevice="$adbdevices"
        return 0
    fi

    local adbdevices=$(adb devices|tail -n+2|awk -F' ' '{ if (length($1)>0) print $1}')
    if [ $? -ne 0 ] ; then
        _log_err "adb device seems to be accessible"
        return 1
    fi

    local nbDevices="$(echo "$adbdevices"|wc -l)"
    if [ $nbDevices -gt 1 ] ; then
        Term__clear
        Input__cursorSelect "${adbdevices}" "${_pal['bg_blue']}Select Android device: ${Term__reset_color}" 1
        local key=$?
        if [ $key -eq 0 ] ; then
            _log_err "Aborted."
            return 1
        fi
        __out_adbdevice="$(echo "$adbdevices"|head -n "$key"|tail -n1)"
    else
        __out_adbdevice="${adbdevices}"
    fi

}

:<<'EOF'
Main network mount function
EOF

Sumo__usb_mount()
{
        SUMO__CURRENT_OPERATION="mount"

        local cmd="Sumo__usb_mount_${SUMO__VARS["NET_PROTO"]}"
        eval "$cmd" 
        local ret=$?
        if [ $ret -eq 0 ] ; then
                local __netref
                Sumo__usb_getDataSourceRef "${SUMO__VARS["DEVPART"]}" __netref
                Sumo__updateSavedRecentList "${__netref}" "${SUMO__VARS["MOUNT_POINT"]} " "" "mount"
        fi
        return $ret
}

:<<'EOF'
Main network unmount function
EOF

Sumo__usb_unmount()
{      
        SUMO__CURRENT_OPERATION="unmount"
        #_log "'${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}'"

        #Sumo__unmountChilds

        local mountpoint="${SUMO__VARS["MOUNT_POINT"]}"

        if [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                if [ ! -z "$mountpoint" ] ; then
                        _quit "Nothing done: $mountpoint is not mounted."
                else
                        _quit "${SUMO__VARS["DEVPART"]} is not mounted."
                fi        
        fi

        _log_dbg "Sumo__usb_unmount Handle unmounting requests MOUNTED:${SUMO__VARS["MOUNTED"]}, MOUNT_POINT:${SUMO__VARS["MOUNT_POINT"]}"
        local ret=0
        local cmd
        local __netref
        Sumo__usb_getDataSourceRef "${SUMO__VARS["DEVPART"]}" __netref

        if [ -v SUMO__VARS["ALL_FLAG"] ] && [ ${#Sumo__targetsListOfMyselfOwner[@]} -gt 1 ] ; then
                for mountpoint in "${Sumo__targetsListOfMyselfOwner[@]}"
                do
                        cmd="Sumo__usb_unmount_${SUMO__VARS["NET_PROTO"]} $mountpoint"
                        eval "$cmd"
                        # This function will use $? returned by eval
                        Sumo__usb_handle_unmount_result "$mountpoint" $?
                        if [ $? -ne 0 ] ; then 
                                ret=-1 
                        else
                                Sumo__updateSavedRecentList "${__netref}" "${mountpoint} " "" "unmount"
                        fi
                done
        else
                cmd="Sumo__usb_unmount_${SUMO__VARS["NET_PROTO"]} $mountpoint"
                eval "$cmd"
                # This function will use $? returned by eval
                Sumo__usb_handle_unmount_result "$mountpoint" $?
                ret=$?
                if [ $ret -ne 0 ] ; then 
                        _log_warn -1 "Failed to unmount '$mountpoint'"
                else
                        Sumo__updateSavedRecentList "${__netref}" "${mountpoint} " "" "unmount"
                fi
        fi
        return $ret
}

:<<'EOF'
Processes the result of the unmount. It prints out a readable result text and
upon success, it removes the mount point folder.
@param [1] mountpoint
@param [2] result (0:success, 1:failure)
@returns the initial value of the result as passed on as second argument
EOF

Sumo__usb_handle_unmount_result()
{
        local mountpoint="$1"
        local res="$2"
        if [ $res -eq 0 ] ; then  
                _log "Successfully unmounted $mountpoint from ${SUMO__VARS["DEVPART"]}"
                if rmdir "$mountpoint" 2>/dev/null; then 
                        if [ -z "${SUMO__VARS["SILENT"]}" ] ; then 
                                _log "Successfully removed the created mount folder '$mountpoint'."
                        fi
                else
                        _log_warn "Created mount folder '$mountpoint' was not removed since it is not empty. Please check and cleanup if necessary."
                fi        
        else
                _log_err "Failed to unmount $mountpoint"
        fi
        return $res
}


Sumo__adb_getExecutablePath()
{
        local -n __out_adbfsExePath=$1
        local installdir="${SUMO__VARS["ADBFS_INSTALL_DIR"]}"
        if [ -z "${installdir}" ] ; then
                installdir="/usr/local/bin"
                _log_warning "'adbfs install dir' parameter is not defined in configuration file. Using ${installdir} as default."
        fi
        __out_adbfsExePath="${installdir}/adbfs"
}

Sumo__usb_mount_adb_install()
{
        ########################################
        # Check if not already available
        local adbfsExePath=""
        Sumo__adb_getExecutablePath adbfsExePath
        if [ -x "${adbfsExePath}" ]; then 
                return 0
        fi

        ########################################
        # Install dependency packages
        _log_warn "adbfs FUSE system is required and is not installed."
        if ! Input__confirm "Do you want to proceed to installation or abort?" ; then
                echo >&2
                _log_err "Mounting of android device ${SUMO__VARS["ADB_DEVICE"]} via adb was aborted".
                return 1
        fi
        echo
        local deps=("libfuse-dev" "adb@adb" "android-tools-adb" "build-essential" "git@git" "pkg-config")
        #android-sdk-platform-tools
        local dep=""
        for dep in "${deps[@]}" ; do
                _log "Checking installation of package '$dep'"
                if ! _loadDep "$dep" ; then _log_err "Failed to load dependency package '$dep'. Aborted" ; return 1; fi
        done

        ########################################
        # Build from git folder

        # Parameters must be read and checked beforehand
        local buildir="${SUMO__VARS["ADBFS_BUILD_DIR"]}"
        if [ -z "${buildir}" ] ; then
                buildir='$HOME'
                _log_warning "'adbfs build dir' parameter is not defined in configuration file. Using ${buildir} as default."
        fi
        if [ ! -d "${buildir}" ] ; then
                local mkdirCmd="mkdir \"${buildir}\" &>/dev/null"
                _logf "MKDIR COMMAND $mkdirCmd"
                if ! eval "$mkdirCmd" ; then
                        _log_err "Failed to create folder '$(eval echo "${buildir}")' to build adbfs-rootless there;"
                        return 1
                fi
        fi
        local gitRepo="${SUMO__VARS["ADBFS_GIT_REPO"]}"
        if [ -z "${gitRepo}" ] ; then
                _log_err "'adbfs git repo' parameter is not defined in configuration file. Aborted."
                return 1        
        fi

        local gitRepoBasename=""
        File__basename "$gitRepo" gitRepoBasename
        local doClone=true

        # Update git if clone target folder exists
        if [ -d "${buildir}/${gitRepoBasename}" ] ; then
                _log "Clone target folder '${buildir}/${gitRepoBasename}' already exists ! Checking if it is a valid git repo and updating it"
                pushd "${buildir}/${gitRepoBasename}" &>/dev/null
                if git status &> /dev/null ; then
                        _log_high "updating $gitRepoBasename"
                        git pull
                        doClone=false
                fi
                popd &>/dev/null
        fi

        # Clone git if clone target folder did not exist
        if $doClone ; then
                pushd "${buildir}" &>/dev/null
                _log_high "Cloning git repository $gitRepo"
                if ! git clone "$gitRepo" ; then
                        _log_err "Cloning from ${gitRepo} failed. Aborted mount operation."
                        popd &>/dev/null
                        return 1
                fi
                popd &>/dev/null
        fi

        pushd "${buildir}/${gitRepoBasename}" &>/dev/null
        _log_high "Building adbfs $gitRepo"
        make
        if [ $? -ne 0 ] ; then
                _log_err "Failed to build ${gitRepoBasename} in $(pwd). Aborted mount operation."
                popd &>/dev/null
                return 1
        fi
        popd &>/dev/null

        ########################################
        # Install binary

        local adbfsBuildExePath="${buildir}/${gitRepoBasename}/adbfs"
        _log_high "Install $adbfsExePath"
        local install_cmd="$(printf "${__SUDO__}install -t /usr/local/bin/ -m %o \"${adbfsBuildExePath}\"" $((0755)))"
        local retValue=0
        _logf "INSTALL COMMAND '${install_cmd}'"
        eval "${install_cmd}"
        retValue=$?
        if [ $retValue -ne 0 ] ; then
                _log_err "Failed to install ${adbfsBuildExePath} into /usr/local/bin/. Aborted mount operation."
        fi
        return 0
}

:<<'EOF'
mount function for SSH
@returns the return value of the mount command evaluation
EOF

Sumo__usb_mount_adb()
{
        if ! Sumo__usb_mount_adb_install ; then return 1; fi

        #_log_high "Sumo__usb_mount_adb passed '${SUMO__VARS["MOUNT_POINT"]}'"
        #exit 0
        local ret=0
        local mountpoint="$1"
        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 
        local specificOptions="${SUMO__VARS["MOUNT_OPTIONS_ADB"]}"

        local adbfsExePath=""
        Sumo__adb_getExecutablePath adbfsExePath
        local mntcmd="\"$adbfsExePath\" "${mntp}""
        local initialOptions=""
        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                initialOptions="-o ${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi

        mntcmd="${mntcmd} ${initialOptions} ${specificOptions} &>> \"${__LOG_ERR_FILE__}\""

        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
        ret=$?
        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}' via adb."
        else
                _log_err "Failed to mount '${mntp}' via adb."
        fi

        return $ret
}

:<<'EOF'
Unmount function for ADB
@returns the return value of the unmount command evaluation
EOF

Sumo__usb_unmount_adb()
{
        #_log_high "Sumo__usb_unmount_adb passed '$1'"
        #exit 0

        local mountpoint="$1"
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-z" ; fi
        local umntcmd="fusermount -u ${lazyOpt} "$mountpoint""
        #local umntcmd="${__SUDO__}fusermount -u ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd"
}


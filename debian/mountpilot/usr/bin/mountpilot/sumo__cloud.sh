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
# Release file path: sumo__cloud.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-10-29 11:38:13.122038571 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to mounting/unmounting of directories located on a cloud
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
Returns the HTTP URL of the cloud from the initialized internal data for a valid cloud
@param [1] ref to var where to store result
@returns 0 there was at least of valid host address available in the internal data, 1 otherwise and no URL is returned.
EOF

Sumo__cloud_getURL()
{
        local -n out_URL=$1
        if [ ! -z "${SUMO__VARS["NET_HOST"]}" ] ; then
                out_URL="https://${SUMO__VARS["NET_HOST"]}"
                if [ ! -z "${SUMO__VARS["NET_PORT"]}" ] && [ "${SUMO__VARS["NET_PORT"]}" != "80" ]  ; then
                        out_URL="${out_URL}:${SUMO__VARS["NET_PORT"]}"
                fi
                return 0
        else
                return 1
        fi
}

:<<'EOF'
Initializes the internal clould identification data from the passed HTTP address
@param [1] Cloud HTTP addres
@returns 1 when the passed address is invalid, 0 otherwise by default.
EOF

Sumo__cloud_setConnectionsInfosFromFileURL() {
        local host=""
        local port=80
        local netRef="$1"
        Str__trim "$netRef" netRef
        Str__trimEnd "$netRef" netRef "/"

        if Net__isHTTP "$netRef" ; then
                _log_dbg "Net__isHTTP!!!!"
                Net__decodeHTTP "$netRef" host port

                if [ -z "$host" ] ; then
                        _susage "Incomplete URL $netRef. Hostname must be defined."
                fi

                # Port is optional default is 80
                SUMO__VARS["NET_PROTO"]="http"
                Net__IP2Name "$host" host                
                SUMO__VARS["NET_HOST"]="$host"
                SUMO__VARS["NET_PORT"]="$port"
                SUMO__VARS["DEVPART"]="$host:$port"
                if [ "${SUMO__VARS["NET_HOST"]}" == "drive.google.com" ] ; then
                        SUMO__VARS["DEVPART"]="google-drive-ocamlfuse"
                        if [ -z "${SUMO__VARS["FS_LABEL"]}" ] ; then
                                SUMO__VARS["FS_LABEL"]="$(id -u -n) google drive"
                        fi
                fi                

                _log_dbg "host:$host"
                _log_dbg "port:$port"
                return 0
        else
                _susage "InvalidURL '$netRef'."
                return 1
        fi        
}

:<<'EOF'
Retrieves the mounting infos according to the internallly stored mount point
and HTTP URL, and sets up the internal network infos from the URL.

Exits the app when requesting to mount on a folder already mounted.
EOF

Sumo__cloud_resolveConnectionsInfos() {
        _log_dbg Sumo__cloud_resolveConnectionsInfos

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
                                return 0
                        else
                                _quit "Folder ${SUMO__VARS["MOUNT_POINT"]} is already mounted from '$foundSource'."
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
        #_log_dbg "MOUNT_POINT_SOURCE: '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'" 
        if [ "${netRef}" == "google-drive-ocamlfuse" ] ; then
                Sumo__cloud_setConnectionsInfosFromFileURL "https://drive.google.com"
        else
                Sumo__cloud_setConnectionsInfosFromFileURL "$netRef"
        fi        
        Sumo__resolveMountingInfos "${SUMO__VARS["DEVPART"]}"
        return 0
}

:<<'EOF'
This function is liable for managing the installation and update the Google Drive OCAML fuse related 
driver and configuration
EOF

Sumo__cloud_loadDep() 
{
        local depName="$1"
        local ocamlfuse_pkg="google-drive-ocamlfuse"

        if [ "$depName" == "$ocamlfuse_pkg" ] || [ "$depName" == "all" ] ; then
                if ! APT__isInstalled "${ocamlfuse_pkg}" ; then
                        local ocamlfuse_ppa="${SUMO__VARS["PPA_GOOGLE-DRIVE-OCAMLFUSE"]}"
                        _log "The installation of the APT package ${ocamlfuse_pkg} requires to add the following PPA repository:"
                        _log "  ${ocamlfuse_ppa}"
                        if Input__confirm "Proceed ?" ; then
                                _log ""
                                _log "Adding repository ${ocamlfuse_ppa}. This may take some time"
                                if ${__SUDO__}sudo add-apt-repository -y -u "${ocamlfuse_ppa}" > /dev/null ; then
                                        Pkg__install "${ocamlfuse_pkg}" "" apt > /dev/null
                                else
                                        return 1
                                fi
                        else
                                return 1
                        fi
                elif [ -v __REFRESH_DEPS__ ] ; then
                        #google-drive-ocamlfuse -cc 
                        ${__SUDO__}rm -rf "$HOME/.gdfuse" 2>/dev/null
                        #${__SUDO__}rm -rf "$HOME/.gdfuse/default" 2>/dev/null
                        SUMO__VARS["GOOGLE_AUTH"]=1 # This forces new authentication
                        Sumo__cloud_mount_google-drive-ocamlfuse_setup_oauth
                        _log_dbg "Sumo__loadDep REINSTALL ${ocamlfuse_pkg}"  
                        Pkg__install "${ocamlfuse_pkg}" "" apt "" "--reinstall" > /dev/null
                fi
        fi
}

:<<'EOF'
Initializes the cloud module from the cloud address stored in SUMO__VARS["IMG_FILE"]}:

It also loads the matching required dependencies according to the type of address used.

The return result is buffered in SUMO__VARS["IMG_FILE_IS_CLOUD_URL"] which is used as reference 
if the function is called again.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__cloud_init()
{
        _log_dbg "Sumo__cloud_isValidAddress: '${SUMO__VARS["IMG_FILE"]}'"
        if [ -v SUMO__VARS["IMG_FILE_IS_CLOUD_URL"] ] ; then
                return ${SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]}
        else        
                SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]=0  # assume it is ok and actually set below
        fi

        local netRef="${SUMO__VARS["IMG_FILE"]}"
        Str__trim "$netRef" netRef
        Str__trimEnd "$netRef" netRef "/"
        if [ "$netRef" == "google-drive-ocamlfuse" ]  || Net__isHTTP "$netRef" ; then
                SUMO__VARS["IMG_FILE_IS_HTTP"]=0
                if [ "${SUMO__VARS["NET_HOST"]}" == "drive.google.com" ] ; then
                        _loadDep "google-drive-ocamlfuse"
                        if [ ! -v SHELL_API_DEP_LOADED["google-drive-ocamlfuse"] ] ; then 
                                _exit -1 "Sorry, the package(s) to support google drive could not be installed. Quitting."
                        fi                
                else
                        SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]=1
                #        _exit -1 "Mounting/unmounting from address '${SUMO__VARS["NET_HOST"]}' is not supported."
                fi
        else
                # No error message, lets main loop go forward
                SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]=1
        fi

        [[ ${SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]} -eq 0 ]]
}

:<<'EOF'
Tests whether the passed argument is valid cloud http address. 
Unless Sumo__cloud_isValidAddress, this function does not alter internal variables. 
@param [1] an explicit cloud http address.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__cloud_isArgValidAddress()
{
        local netRef="$1"
        Str__trim "$netRef" netRef 
        Str__trimEnd "$netRef" netRef "/"
        if [ "$netRef" == "google-drive-ocamlfuse" ]  || Net__isHTTP "$netRef" ; then
                return 0
        else
                return 1
        fi
}

:<<'EOF'
Main function for handling cloud-based mounting/unmounting, e.g. over SMB or sSH
EOF

Sumo__cloud()
{
        _log_dbg "Sumo__cloud src='${SUMO__VARS["MOUNT_POINT_SOURCE"]}' IMG_FILE='${SUMO__VARS["IMG_FILE"]}' DEVPART:'${SUMO__VARS["DEVPART"]}'"
        local netRef=""

        if ! Sumo__cloud_isArgValidAddress "${SUMO__VARS["IMG_FILE"]}" || ([ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] && [ ! -z "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ]); then
                if  Sumo__cloud_isArgValidAddress "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ; then
                        if Net__isHTTP "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ; then
                                Sumo__cloud_setConnectionsInfosFromFileURL "${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                                Sumo__resolveMountingInfos "${SUMO__VARS["DEVPART"]}"
                        else
                                SUMO__VARS["DEVPART"]="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                        fi
                else
                        return 1
                fi
        else
                netRef="${SUMO__VARS["IMG_FILE"]}"
                Str__trim "$netRef" netRef
                Str__trimEnd "$netRef" netRef "/"
                SUMO__VARS["IMG_FILE"]="$netRef"

                if ! Sumo__cloud_resolveConnectionsInfos ; then
                        _exit -6 "Failed to resolve mount source." 
                fi
        fi

        Sumo__cloud_init

        # Handle unmounting requests
        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
                Sumo__cloud_unmount
                _exit $? ""
        else
                Sumo__cloud_determineMountPoint
                Sumo__cloud_mount
                _exit $? ""
        fi

        return 0
}

:<<'EOF'
Function used to determine or let user enter the mountpoint
EOF

Sumo__cloud_determineMountPoint()
{
        _log_dbg "Sumo__cloud_determineMountPoint mountpoint='${SUMO__VARS["MOUNT_POINT"]}' IMG_FILE='${SUMO__VARS["IMG_FILE"]}' DEVPART:'${SUMO__VARS["DEVPART"]}'"

        if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] && [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                Sumo__manageValidMountpointSetting Sumo__cloud_getMountpoint "${SUMO__VARS["MOUNT_POINT"]}"
        elif Net__isHTTP "${SUMO__VARS["IMG_FILE"]}" ; then
                Sumo__manageValidMountpointSetting Sumo__cloud_getMountpoint
        else                
                _exit -55 "Internal error: unhandled cloud URL ${SUMO__VARS["IMG_FILE"]}. Please report." # We should never arrive here since tested beforehand
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

Sumo__cloud_getMountpoint()
{
        local cnt=$1
        local -n out_default_mp=$2
        local hostname=""
        local foreignLoginSubfolder=""
        local pathSubfolder=""

        if [ -z "${SUMO__VARS["NET_HOSTNAME"]}" ] ; then
                Net__getHostname "${SUMO__VARS["NET_HOST"]}" hostname
                SUMO__VARS["NET_HOSTNAME"]="$hostname"
        else
                hostname="${SUMO__VARS["NET_HOSTNAME"]}"
        fi
        if [ "${SUMO__VARS["NET_LOGIN"]}" != "$(whoami)" ] ; then 
                foreignLoginSubfolder="/${SUMO__VARS["NET_LOGIN"]}"; 
        fi

        if [ "${SUMO__VARS["NET_PATH"]}" != "." ] && [ ! -z "${SUMO__VARS["NET_PATH"]}" ] ; then pathSubfolder="/${SUMO__VARS["NET_PATH"]}" ; fi
        if [ $cnt -eq 0 ] ; then
                out_default_mp="@${hostname}${foreignLoginSubfolder}${pathSubfolder}"
        else
                out_default_mp="@${hostname}:${cnt}${foreignLoginSubfolder}${pathSubfolder}"
        fi
        return 0        
}


:<<'EOF'
Main cloud mount function
EOF

Sumo__cloud_mount()
{
        SUMO__CURRENT_OPERATION="mount"

        local cmd="Sumo__cloud_mount_${SUMO__VARS["DEVPART"]}"
        local ret
        eval "$cmd" 
        ret=$?
        if [ $ret -eq 0 ] ; then
                local _cloudURL
                Sumo__cloud_getURL _cloudURL # Get the URL for the infos parsed in Sumo__cloud_setConnectionsInfosFromFileURL
                Sumo__updateSavedRecentList "${_cloudURL}" "${SUMO__VARS["MOUNT_POINT"]} " "" "mount"
        fi
        return $ret
}

:<<'EOF'
Main cloud unmount function
EOF

Sumo__cloud_unmount()
{      
        SUMO__CURRENT_OPERATION="unmount"

        local mountpoint="${SUMO__VARS["MOUNT_POINT"]}"

        if [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                if [ ! -z "$mountpoint" ] ; then
                        _quit "Nothing done: $mountpoint is not mounted."
                else
                        _quit "${SUMO__VARS["DEVPART"]} is not mounted."
                fi        
        fi

        _log_dbg "Sumo__cloud Handle unmounting requests"
        local ret=0
        local cmd
        if [ -v SUMO__VARS["ALL_FLAG"] ] && [ ${#Sumo__targetsListOfMyselfOwner[@]} -gt 1 ] ; then
                for mountpoint in "${Sumo__targetsListOfMyselfOwner[@]}"
                do
                        cmd="Sumo__cloud_unmount_${SUMO__VARS["DEVPART"]} $mountpoint"
                        eval "$cmd"
                        Sumo__cloud_handle_unmount_result "$mountpoint" $?
                        if [ $? -ne 0 ] ; then 
                                ret=-1 
                        else
                                local _cloudURL
                                Net__getCloudURLFromDevice "${SUMO__VARS["DEVPART"]}" _cloudURL 
                                Sumo__updateSavedRecentList "${_cloudURL}" "${mountpoint} " "" "unmount"
                        fi
                done
        else
                cmd="Sumo__cloud_unmount_${SUMO__VARS["DEVPART"]} $mountpoint"
                eval "$cmd"
                Sumo__cloud_handle_unmount_result "$mountpoint" $?
                ret=$?
                if [ $ret -ne 0 ] ; then 
                        _log_warn -1 "Failed to unmount '$mountpoint'"
                else
                        local _cloudURL
                        Net__getCloudURLFromDevice "${SUMO__VARS["DEVPART"]}" _cloudURL 
                        Sumo__updateSavedRecentList "${_cloudURL}" "${mountpoint} " "" "unmount"
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

Sumo__cloud_handle_unmount_result()
{
        local mountpoint="$1"
        local res="$2"
        if [ $res -eq 0 ] ; then  
                _log "Successfully unmounted $mountpoint" # from ${SUMO__VARS["NET_HOST"]}"
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

Sumo__cloud_mount_google-drive-ocamlfuse_setup_oauth()
{
        local auth="google-drive-ocamlfuse"
        local myCfgFile=""
        local sumoCfgFile=""
        _getConfigFilePath myCfgFile
        Sumo__getDefaultConfigFile sumoCfgFile
        local cfg_perm_install_cmd="${__SUDO__}chown ${USER}:${USER} \"$myCfgFile\" && chmod 0600 \"$myCfgFile\""

        _log_dbg "Sumo__cloud_mount_google-drive-ocamlfuse_setup_oauth"

        if [ "${SUMO__VARS["GOOGLE_AUTH"]}" == "0" ] ; then
                # Ensure safe file configuration access, since it contains private Google IDs
                eval "${cfg_perm_install_cmd}" &>/dev/null
                return 0 # OK, authentication was done before
        elif [ ! -z "${SUMO__VARS["GOOGLE_CLIENT_ID"]}" ] &&  [ ! -z "${SUMO__VARS["GOOGLE_SECRET_ID"]}" ] ; then
                if [ ! -f "$myCfgFile" ] ; then
                        cp "$sumoCfgFile" "$myCfgFile"
                        if [ $? -ne 0 ] ; then
                                _exit -60 "Failed to create initial user configuration file '$myCfgFile'"
                        fi
                fi
                # Ensure safe file configuration access, since it contains private Google IDs
                #auth="${auth} -headless"
                eval "${cfg_perm_install_cmd}" &>/dev/null
                auth="${auth} -label \"${SUMO__VARS["FS_LABEL"]}\""
                auth="${auth} -id ${SUMO__VARS["GOOGLE_CLIENT_ID"]}"
                auth="${auth} -secret ${SUMO__VARS["GOOGLE_SECRET_ID"]}"
                _logf "$auth"
                eval "$auth"  2>>"${__LOG_ERR_FILE__}"
                if [ $? -eq 0 ] ; then
                        #echo "" >> "$myCfgFile"
                        #echo "google auth: done" >> "$myCfgFile"
                        return 0
                else
                        _exit -60 "An error occurred during Google verification."
                fi
        else
cat<<EOF >&2

To access your Google Drive, you need first to get your Client ID and Secret ID from Google. 
For that purpose, please check the instructions given in the man page.

Once you put your Client ID and Secret ID in your configuration file '$myCfgFile', type 
   sumo drive.google.com

If you have no configuration file yet, type before
   cp "$sumoCfgFile" "$myCfgFile"

The first time, you will be prompted for a verification code on a Google page. 
Copy the verification code from the opened web page and paste it in the console when prompted.

EOF
                _quit ""
        fi

}

:<<'EOF'
mount function for google drive

@returns the return value of the mount command evaluation
EOF

Sumo__cloud_mount_google-drive-ocamlfuse()
{
        local ret=0
        local mountpoint="$1"
        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 
        local mntcmd="google-drive-ocamlfuse"
        local options="${SUMO__VARS["MOUNT_OPTIONS_GOOGLE-DRIVE-OCAMLFUSE"]}"

        mntcmd="${mntcmd} ${options}"

        if ! Sumo__cloud_mount_google-drive-ocamlfuse_setup_oauth ; then return 1; fi

        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                mntcmd="${mntcmd} -o ${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi

        mntcmd="${mntcmd} -id ${SUMO__VARS["GOOGLE_CLIENT_ID"]}"
        mntcmd="${mntcmd} -secret ${SUMO__VARS["GOOGLE_SECRET_ID"]}"

        mntcmd="${mntcmd} \"$mntp\""
        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
        ret=$?
        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}'."
        else
                _log_err "Failed to mount '${mntp}'."
        fi

        return $ret
}

:<<'EOF'
Unmount function for google drive
@returns the return value of the unmount command evaluation
EOF

Sumo__cloud_unmount_google-drive-ocamlfuse()
{
        local mountpoint="$1"
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-z" ; fi
        local umntcmd="${__SUDO__}fusermount -u ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd" 2>>"${__LOG_ERR_FILE__}"
}

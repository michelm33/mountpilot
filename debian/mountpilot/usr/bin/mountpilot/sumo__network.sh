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
# Release file path: sumo__network.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-08 09:41:11.101196419 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to mounting/unmounting over the network
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
Initializes
SUMO__VARS["NET_HOST"]
SUMO__VARS["NET_IP"]
SUMO__VARS["NET_HOSTNAME"]
from the passed argument, which can be an ip or a name
EOF
Sumo__network__resolveNetAddresses()
{
        local __in_arg="$1"   
        local __ip=""
        local __hostname=""

        Net__resolve "${__in_arg}" __ip __hostname
        if [ $? -ne 0 ] ; then
                if Net__isIP "${__in_arg}" ; then
                    _log_warn "Failed to resolve hostname for ${__in_arg}"
                    #__ip="${__in_arg}"
                    #Net__getLocalHostname __hostname
                else
                    _log_warn "Failed to resolve IP for hostname ${__in_arg}"
                    #__hostname="${__in_arg}"
                    #Net__getLocalHostIP __ip 
                fi
        fi
        
        #_log_dbg "Net__resolve: ${__ip} === > '${__hostname}'"
        SUMO__VARS["NET_IP"]="${__ip}"
        if [ -z "${__hostname}" ] ; then
                SUMO__VARS["NET_HOST"]="${__ip}"
                SUMO__VARS["NET_HOSTNAME"]="${__ip}"
        else
                SUMO__VARS["NET_HOST"]="${__hostname}"
                SUMO__VARS["NET_HOSTNAME"]="${__hostname}"
        fi
}

:<<'EOF'
Sets up internal network infos from the URL: host, user, share, password, path
EOF
Sumo__network_setConnectionsInfosFromFileURL() {
        local host=""
        local user=""
        local share=""
        local passwd=""
        local path=""
        local port=0

        local netRef="$1"
        Str__trim "$netRef" netRef
        Str__trimEnd "$netRef" netRef "/"

        if Net__isUNC "$netRef" ; then
                _log_dbg "Net__isUNC!!!!"
                SUMO__VARS["DEVPART"]="$netRef"

                Net__decodeUNC "${SUMO__VARS["DEVPART"]}" host share
                SUMO__VARS["NET_PROTO"]="cifs"
                # SUMO__VARS["NET_LOGIN"]="" # NO, may be defined by arguments
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host
                if [ -z "${SUMO__VARS["NET_HOST"]}" ] ; then
                        SUMO__VARS["NET_HOST"]="$host"
                fi
                _log_dbg "Net__isUNC: IP is '${SUMO__VARS["NET_IP"]}'"

                SUMO__VARS["NET_SHARE"]="$share" 

        elif Net__isLogin "$netRef" ; then
                _log_dbg "Net__isLogin!!!!"

                Net__decodeLogin "$netRef" host user path
                SUMO__VARS["NET_PROTO"]="ssh"
                SUMO__VARS["NET_LOGIN"]="$user"
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host
                #SUMO__VARS["NET_HOST"]="$host"

                SUMO__VARS["NET_SHARE"]="" 

                if [ -z "$path" ] ; then
                        SUMO__VARS["NET_PATH"]="."
                else
                        SUMO__VARS["NET_PATH"]="$path"
                fi
                SUMO__VARS["DEVPART"]="${user}@$host:${SUMO__VARS["NET_PATH"]}"

        elif Net__isSMBURL "$netRef" ; then
                _log_dbg "Net__isSMBURL!!!!"
                Net__decodeSMBURL "$netRef" host user passwd share 
                if [ ! -z "$passwd" ] ; then
                        SUMO__VARS["PASSPHRASE"]="$passwd" # may be specified with -p as well
                fi
                if [ ! -z "$user" ] ; then
                        SUMO__VARS["NET_LOGIN"]="$user" # may be specified with ---user as well
                fi

                if [ -z "$host" ] ; then
                        _susage "Incomplete URL $netRef. Hostname must be defined."
                fi
                if [ -z "$share" ] ; then
                        _susage "Incomplete URL $netRef. Name of share must be defined."
                fi          

                SUMO__VARS["NET_PROTO"]="cifs"
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host
                #SUMO__VARS["NET_HOST"]="$host"
                SUMO__VARS["NET_SHARE"]="$share" 
                SUMO__VARS["DEVPART"]="//$host/$share"

        elif Net__isSSHURL "$netRef" ; then
                _log_dbg "Net__isSSHURL!!!!"
                # share contains the port number
                Net__decodeSSHURL "$netRef" host user passwd share path
                if [ ! -z "$passwd" ] ; then
                        SUMO__VARS["PASSPHRASE"]="$passwd" # may be specified with -p as well
                fi
                if [ ! -z "$user" ] ; then
                        SUMO__VARS["NET_LOGIN"]="$user" # may be specified with ---user as well
                else    
                        SUMO__VARS["NET_LOGIN"]="$(whoami)"
                fi
                SUMO__VARS["NET_SHARE"]=""
                #if [ ! -z "$share" ] ; then
                #        SUMO__VARS["NET_SHARE"]="${user}@${host}:${share}"  # the share here is the port number
                #else
                #        SUMO__VARS["NET_SHARE"]="${user}@${host}:22"  # the share here is the port number
                #fi

                if [ -z "$path" ] ; then
                        SUMO__VARS["NET_PATH"]="."
                else
                        SUMO__VARS["NET_PATH"]="$path"
                fi

                if [ -z "$host" ] ; then
                        _susage "Incomplete URL $netRef. Hostname must be defined."
                fi

                # Port is optional default is 22

                SUMO__VARS["NET_PROTO"]="ssh"
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host                
                #SUMO__VARS["NET_HOST"]="$host"
                SUMO__VARS["DEVPART"]="${user}@$host:${SUMO__VARS["NET_PATH"]}"

        elif Net__isFTPURL "$netRef" ; then
                _log_dbg "Net__isFTPURL!!!!"
                # share contains the port number
                Net__decodeFTPURL "$netRef" host user passwd port
                if [ ! -z "$passwd" ] ; then
                        SUMO__VARS["PASSPHRASE"]="$passwd" # may be specified with -p as well
                fi
                if [ ! -z "$user" ] ; then
                        # Case where login was given inside URL
                        SUMO__VARS["NET_LOGIN"]="$user" 
                elif [ ! -z "${SUMO__VARS["NET_LOGIN"]}" ] ; then
                        # Case where login was set by option -U --user 
                        user="${SUMO__VARS["NET_LOGIN"]}"
                else  
                        # Else we take curent user by default
                        user="$(whoami)"
                        SUMO__VARS["NET_LOGIN"]="$user"
                fi
                SUMO__VARS["NET_PORT"]="$port"
                SUMO__VARS["NET_SHARE"]=""
                SUMO__VARS["NET_PATH"]=""

                if [ -z "$host" ] ; then
                        _susage "Incomplete URL $netRef. Hostname must be defined."
                fi

                # Port is optional default is 21

                SUMO__VARS["NET_PROTO"]="ftp"
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host                
                #SUMO__VARS["NET_HOST"]="$host"

                if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
                        # The curl device mandatory contains a login name
                        # for entry of one if none supplied
                        if [ -z "${user}" ] ; then
                                Sumo__network_requestLogin
                        fi
                fi

                SUMO__VARS["DEVPART"]="curlftpfs#ftp://${user}@$host/"

        elif Net__isNFSURL "$netRef" || Net__isNFS "$netRef" ; then
                _log_dbg "Net__isNFSURL!!!!"
                # share contains the port number
                Net__decodeNFSURL "$netRef" host path
                SUMO__VARS["NET_LOGIN"]=""
                SUMO__VARS["NET_LOGIN_REQUIRED"]="no"
                SUMO__VARS["NET_SHARE"]=""

                if [ -z "$path" ] ; then
                        SUMO__VARS["NET_PATH"]="$HOME"
                else
                        SUMO__VARS["NET_PATH"]="$path"
                fi

                if [ -z "$host" ] ; then
                        _susage "Incomplete URL $netRef. Hostname must be defined."
                fi

                # Port is optional default is 22

                SUMO__VARS["NET_PROTO"]="nfs"
                Sumo__network__resolveNetAddresses "$host"
                #Net__IP2Name "$host" host                
                #SUMO__VARS["NET_HOST"]="$host"
                if [ ! -z "${SUMO__VARS["NET_HOSTNAME"]}" ] ; then
                        host="${SUMO__VARS["NET_HOSTNAME"]}"
                fi
                SUMO__VARS["DEVPART"]="$host:${SUMO__VARS["NET_PATH"]}"


        else
                _susage "Invalid URL '$netRef'."
        fi        

        SUMO__VARS["DEVMAPPER"]="${SUMO__VARS["DEVPART"]}"
        _log_dbg "host:$host"
        _log_dbg "user:$user"
        _log_dbg "passwd:$passwd"
        _log_dbg "share:'$share'"
        _log_dbg "SUMO__VARS["DEVMAPPER"]:'${SUMO__VARS["DEVMAPPER"]}'"

}

:<<'EOF'
Retrieves the mounting infos according to the internallly stored mount point
and UNC/SSH login, and sets up the internal network infos from the URL.

Exits the app when requesting to mount on a folder already mounted.
EOF

Sumo__network_resolveConnectionsInfos() {
        _log_dbg Sumo__network_resolveConnectionsInfos

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
        Sumo__network_setConnectionsInfosFromFileURL "${SUMO__VARS["IMG_FILE"]}" # This shall set SUMO__VARS["DEVPART"]
        Sumo__resolveMountingInfos "${SUMO__VARS["DEVPART"]}"
        return 0
}

:<<'EOF'
Initializes the network module from the network address stored in SUMO__VARS["IMG_FILE"]}:

- SSH URL :     ssh://[user@]host[:port][/path]
- SSH login:    <user>@<host>[:path]
- SMB URL :     smb://<hostname or IP>[/<user>[:password][/<share>]]
- UNC:          //server/sharename[/path]

It also loads the matching required dependencies according to the type of address used.

The return result is buffered in SUMO__VARS["IMG_FILE_IS_URL"] which is used as reference 
if the function is called again.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__network_init()
{
        if [ -v SUMO__VARS["IMG_FILE_IS_URL"] ] ; then
                return ${SUMO__VARS["IMG_FILE_IS_URL"]}
        else        
                SUMO__VARS["IMG_FILE_IS_URL"]=0  # assume it is ok and actually set below
        fi

        local netRef="${SUMO__VARS["IMG_FILE"]}"
        Str__trim "$netRef" netRef
        Str__trimEnd "$netRef" netRef "/"

        if Net__isSMBURL "$netRef" || Net__isUNC "$netRef" ; then
                if Net__isUNC "$netRef" ; then 
                        SUMO__VARS["IMG_FILE_IS_UNC"]=0
                fi
                _loadDep "smb"
                if [ ! -v SHELL_API_DEP_LOADED["smb"] ] ; then
                        _exit -1 "Sorry, the package(s) to support Windows shares could not be installed. SAMBA URLs are no supported."
                fi
        elif Net__isSSHURL "$netRef" || Net__isLogin "$netRef" ; then
                if Net__isLogin "$netRef" ; then 
                        SUMO__VARS["IMG_FILE_IS_LOGIN"]=0
                fi
                _loadDep "sshfs"
                _loadDep "openssh-client"               # ssh-add, ssh-keygen, ssh-copy-id
                if [ ! -v SHELL_API_DEP_LOADED["sshfs"] ] ; then 
                        _exit -1 "Sorry, the package(s) to support SSH FS could not be installed. SSH URLs are no supported."
                fi
        elif Net__isFTPURL "$netRef" ; then
                _loadDep "curlftpfs"
                _loadDep "nmap"
                if [ ! -v SHELL_API_DEP_LOADED["curlftpfs"] ] ; then 
                        _exit -1 "Sorry, the package curlftpfs to support FTP could not be installed. FTP is not supported."
                fi
        elif Net__isNFSURL "$netRef" || Net__isNFS "$netRef" ; then
                _log_dbg "Sumo__network_init : NFS "
                _loadDep "nfs-common"
                _loadDep "putty-tools"
                _loadDep "nmap"

                if [ ! -v SHELL_API_DEP_LOADED["nfs-common"] ] ; then 
                        _exit -1 "Sorry, the package(s) 'nfs-common' to support NFS could not be installed. NFS URLs are no supported."
                fi
                if [ ! -v SHELL_API_DEP_LOADED["putty-tools"] ] ; then 
                        _exit -1 "Sorry, the package(s) 'putty-tools' could not be installed. NFS URLs are no supported."
                fi
        else
                # No error message, lets main loop go forward
                SUMO__VARS["IMG_FILE_IS_URL"]=1
        fi

        return ${SUMO__VARS["IMG_FILE_IS_URL"]}
}

Sumo__network_getSumoNetRef()
{
        local originalSrc="$1"
        local -n convertedSrc="$2"
        if [ "${SUMO__VARS["NET_PROTO"]}" = "ssh" ] ; then                
                convertedSrc="${SUMO__VARS["NET_LOGIN"]}@${SUMO__VARS["NET_HOSTNAME"]}:${SUMO__VARS["NET_PATH"]}"
        elif [ "${SUMO__VARS["NET_PROTO"]}" = "nfs" ] ; then                
                convertedSrc="nfs://${SUMO__VARS["DEVPART"]}"
        elif [ "${SUMO__VARS["NET_PROTO"]}" = "ftp" ] ; then                
                convertedSrc="ftp://${SUMO__VARS["NET_LOGIN"]}@${SUMO__VARS["NET_HOSTNAME"]}/"
        else
                convertedSrc="${SUMO__VARS["DEVPART"]}"
        fi
}

:<<'EOF'
Tests whether the passed argument is valid network address. 
Unless Sumo__network_isValidAddress, this function does not alter internal variables. 
@param [1] an explicit network address.
@return true (0) if valid address, 1 otherwise.
EOF

Sumo__network_isArgValidAddress()
{
        local netRef="$1"
        Str__trim "$netRef" netRef 
        Str__trimEnd "$netRef" netRef "/"

        if Net__isUNC "$netRef" ; then
                return 0
        elif Net__isLogin "$netRef" ; then
                return 0
        elif Net__isSMBURL "$netRef" ; then
                return 0
        elif Net__isSSHURL "$netRef" ; then
                return 0
        elif Net__isFTPURL "$netRef" ; then
                return 0
        elif Net__isNFS "$netRef" ; then
                return 0
        elif Net__isNFSURL "$netRef" ; then
                return 0
        else
                return 1
        fi
}

:<<'EOF'
Main function for handling network-based mounting/unmounting, e.g. over SMB or sSH
EOF

Sumo__network()
{
        #_log_dbg "Sumo__network"
        local netRef=""
        #_log "Sumo__network '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}'"

        if ! Sumo__network_isArgValidAddress "${SUMO__VARS["IMG_FILE"]}"; then
                #_log "Sumo__network ELSE Sumo__network_isArgValidAddress '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
                        if [ ! -z "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ] && Sumo__network_isArgValidAddress "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ; then
                                #_log "Sumo__network MOUNT_POINT_SOURCE Sumo__network_isArgValidAddress '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                                Sumo__network_setConnectionsInfosFromFileURL "${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                                #SUMO__VARS["DEVPART"]="$foundSource"
                                Sumo__resolveMountingInfos "${SUMO__VARS["MOUNT_POINT_SOURCE"]}"
                        else
                                #_log "Sumo__network return 1 Sumo__network_isArgValidAddress '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                                return 1
                        fi
                else
                        #_log "Sumo__network return 1 no2 Sumo__network_isArgValidAddress '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"

                        return 1
                fi
        else
                #_log "Sumo__network ELSE Sumo__network_isArgValidAddress '${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}' '${SUMO__VARS["DEVMAPPER"]}' '${SUMO__VARS["MOUNT_POINT_SOURCE"]}'"
                netRef="${SUMO__VARS["IMG_FILE"]}"
                Str__trim "$netRef" netRef
                Str__trimEnd "$netRef" netRef "/"
                SUMO__VARS["IMG_FILE"]="$netRef"

                if ! Sumo__network_resolveConnectionsInfos ; then
                        _exit -6 "Failed to resolve mount source." 
                fi
        fi

        Sumo__network_init

        # Handle unmounting requests
        local ret
        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
                Sumo__network_unmount
                ret=$?
        else
                Sumo__network_determineMountPoint
                Sumo__network_mount
                ret=$?
        fi

        _exit $ret ""
}

:<<'EOF'
Function used to determine or let user enter the mountpoint and the name of the share if address is SMB or UNC
EOF

Sumo__network_determineMountPoint()
{
        if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] && [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                Sumo__manageValidMountpointSetting Sumo__network_getMountpoint "${SUMO__VARS["MOUNT_POINT"]}"
        elif Net__isSMBURL "${SUMO__VARS["IMG_FILE"]}" || ([ -v SUMO__VARS["IMG_FILE_IS_UNC"] ] && [ ${SUMO__VARS["IMG_FILE_IS_UNC"]} -eq 0 ]) ; then
                local sharename=""
                if [ -z "${SUMO__VARS["NET_SHARE"]}" ] ; then
                        if Input__Word "Enter name of share which is made available by the remote host" "Data" sharename ; then
                                SUMO__VARS["NET_SHARE"]="$sharename"
                        else
                                _exit -6 "Abort. A valid share is required." 
                        fi
                fi          
                Sumo__manageValidMountpointSetting Sumo__network_getMountpoint
        elif Net__isSSHURL "${SUMO__VARS["IMG_FILE"]}" || [ ${SUMO__VARS["IMG_FILE_IS_LOGIN"]} -eq 0 ] ; then
                Sumo__manageValidMountpointSetting Sumo__network_getMountpoint
        elif Net__isFTPURL "${SUMO__VARS["IMG_FILE"]}"  ; then
                Sumo__manageValidMountpointSetting Sumo__network_getMountpoint
        elif Net__isNFSURL "${SUMO__VARS["IMG_FILE"]}" || Net__isNFS "${SUMO__VARS["IMG_FILE"]}" ; then
                Sumo__manageValidMountpointSetting Sumo__network_getMountpoint
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

Sumo__network_getMountpoint()
{
        #_log "Sumo__network_getMountpoint '$1' '$2'" # DEBUG
        local cnt=$1
        local -n out_default_mp=$2
        local hostname=""
        local foreignLoginSubfolder=""
        local pathSubfolder=""
        local shareSubfolder=""

        if [ -z "${SUMO__VARS["NET_HOSTNAME"]}" ] ; then
                Net__getHostname "${SUMO__VARS["NET_HOST"]}" hostname
                SUMO__VARS["NET_HOSTNAME"]="$hostname"
        else
                hostname="${SUMO__VARS["NET_HOSTNAME"]}"
        fi
        if [ "${SUMO__VARS["NET_LOGIN"]}" != "$(whoami)" ] ; then 
                foreignLoginSubfolder="/${SUMO__VARS["NET_LOGIN"]}"; 
        fi

        shareSubfolder="/${SUMO__VARS["NET_SHARE"]}"
        if [ "${SUMO__VARS["NET_PATH"]}" != "." ] && [ ! -z "${SUMO__VARS["NET_PATH"]}" ] ; then pathSubfolder="/${SUMO__VARS["NET_PATH"]}" ; fi
        if [ $cnt -eq 0 ] ; then
                out_default_mp="@${hostname}${foreignLoginSubfolder}${shareSubfolder}${pathSubfolder}"
        else
                out_default_mp="@${hostname}:${cnt}${foreignLoginSubfolder}${shareSubfolder}${pathSubfolder}"
        fi
        return 0        
}


:<<'EOF'
This function enables to force entry of a user login if none was supplied/known from URL ANd if it is required
according to SUMO__VARS["NET_LOGIN_REQUIRED"]
EOF


Sumo__network_requestLogin()
{
        if [ -z "${SUMO__VARS["NET_LOGIN"]}" ] && [ "${SUMO__VARS["NET_LOGIN_REQUIRED"]}" != "no" ] ; then
                local username=""
                local forcedInput
                Input__getForcedInput forcedInput
                if [ "$forcedInput" == "y" ] ; then # Force user to enter a valid user name
                        Input__popForcedInput
                fi
                if Input__Word "Enter user name to login the remote host" "$(whoami)" username ; then
                        SUMO__VARS["NET_LOGIN"]="$username"
                else
                        _exit -6 "Abort. A valid user login has to be entered and enter it using --user option"                
                fi
                if [ "$forcedInput" == "y" ] ; then
                        Input__pushForcedInput "$forcedInput" 
                fi
        fi
}

:<<'EOF'
Main network mount function
EOF

Sumo__network_mount()
{
        SUMO__CURRENT_OPERATION="mount"

        Sumo__network_requestLogin        

        local cmd="Sumo__network_mount_${SUMO__VARS["NET_PROTO"]}"
        eval "$cmd" 
        local ret=$?
        if [ $ret -eq 0 ] ; then
                local __netref
                Sumo__network_getSumoNetRef "${SUMO__VARS["DEVPART"]}" __netref
                Sumo__updateSavedRecentList "${__netref}" "${SUMO__VARS["MOUNT_POINT"]} " "" "mount"
        fi
        return $ret
}

:<<'EOF'
Main network unmount function
EOF

Sumo__network_unmount()
{      
        SUMO__CURRENT_OPERATION="unmount"
        #_log "'${SUMO__VARS["NET_PROTO"]}' '${SUMO__VARS["DEVPART"]}'"

        Sumo__unmountChilds

        local mountpoint="${SUMO__VARS["MOUNT_POINT"]}"

        if [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
                if [ ! -z "$mountpoint" ] ; then
                        _quit "Nothing done: $mountpoint is not mounted."
                else
                        _quit "${SUMO__VARS["DEVPART"]} is not mounted."
                fi        
        fi

        _log_dbg "Sumo__network Handle unmounting requests"
        local ret=0
        local cmd
        local __netref
        Sumo__network_getSumoNetRef "${SUMO__VARS["DEVPART"]}" __netref

        if [ -v SUMO__VARS["ALL_FLAG"] ] && [ ${#Sumo__targetsListOfMyselfOwner[@]} -gt 1 ] ; then
                for mountpoint in "${Sumo__targetsListOfMyselfOwner[@]}"
                do
                        cmd="Sumo__network_unmount_${SUMO__VARS["NET_PROTO"]} $mountpoint"
                        eval "$cmd"
                        # This function will use $? returned by eval
                        Sumo__network_handle_unmount_result "$mountpoint" $?
                        if [ $? -ne 0 ] ; then 
                                ret=-1 
                        else
                                Sumo__updateSavedRecentList "${__netref}" "${mountpoint} " "" "unmount"
                        fi
                done
        else
                cmd="Sumo__network_unmount_${SUMO__VARS["NET_PROTO"]} $mountpoint"
                eval "$cmd"
                # This function will use $? returned by eval
                Sumo__network_handle_unmount_result "$mountpoint" $?
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

Sumo__network_handle_unmount_result()
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

:<<'EOF'
Mount function for CIFS
@returns the return value of the mount command evaluation
EOF

Sumo__network_mount_cifs()
{        
        local handleTimeoutOption=""
        if [ -z "${SUMO__VARS["MOUNT__CIFS"]}" ] ; then
                SUMO__VARS["MOUNT__CIFS"]=`${__SUDO__} mount.cifs -V|cut -d ':' -f2|tr -d ' '`
        fi
        if [ ! -z "${SUMO__VARS["MOUNT__CIFS"]}" ] ; then
                local hTAvail
                hTAvail=$(echo "${SUMO__VARS["MOUNT__CIFS"]} >= 6.9" | bc)
                if [ $? -eq 0 ] && [ $hTAvail -eq 1 ] ; then
                        handleTimeoutOption="handletimeout=1"
                fi
        fi

        local ret=0
        local UNC="//${SUMO__VARS["NET_HOST"]}/${SUMO__VARS["NET_SHARE"]}" 
        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 
        #_log "${__SUDO__}mount -t ${SUMO__VARS["NET_PROTO"]} ${UNC} ${mntp} -o handletimeout=1,user=${SUMO__VARS["NET_LOGIN"]},uid=$(whoami),gid=$(id -g -n $(whoami))"

        # resilienthandles or persistenthandles
        # handletimeout=arg
        #        echo_interval=n
        # x-systemd.idle-timeout=10,


        local mntcmd="${__SUDO__}mount.cifs "${UNC}" "${mntp}" -o ${handleTimeoutOption},username="${SUMO__VARS["NET_LOGIN"]}",uid=$(id -u),gid=$(id -g ${SUMO__VARS["OWNER"]})"

        if [ ! -z "${SUMO__VARS["PASSPHRASE"]}" ] ; then
                mntcmd="${mntcmd},password='${SUMO__VARS["PASSPHRASE"]}'"
        fi
        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                mntcmd="${mntcmd},${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi

        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd"
        ret=$?

        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}' from '${UNC}'."
        else
                _log_err "Failed to mount '${mntp}' from '${UNC}'."
        fi        
        # List
        #Sumo__listCurrentDevice 

        return $ret
}

:<<'EOF'
Unmount function for CIFS
@returns the return value of the unmount command evaluation
EOF

Sumo__network_unmount_cifs()
{
        local mountpoint="$1"
        # There is no gyarantee that umount does not block even when using lazy
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-l -f" ; fi
        local umntcmd="timeout -s SIGKILL 3 ${__SUDO__}umount ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd" &> /dev/null
}

:<<'EOF'
Checks whether autossh login is already installed for a target address and proceed
to the seamless setup of auto SSH login on demand, based on ssh-keygen and ssh-copy-id.
EOF

Sumo__network_handle_ssh_key_install()
{
        local login="$1"
        local localKeyAvail=1
        local remoteKeyNotInstalled=1
        local sshcopyOutput=""
        
        sshcopyOutput="$(ssh-add -L 2>>"${__LOG_ERR_FILE__}")"
        local resSshList=$?
        if [ $resSshList -eq 0 ] ; then
                if [ ! -z "${sshcopyOutput}" ] ; then
                        localKeyAvail=0
                fi
        elif [ $resSshList -eq 2 ] ; then
                _log_warn "ssh-add is unable to contact the authentication agent. Assuming a local key is available. "
                Input__confirm "Please confirm if a local key is available"
                if [ $? -eq 0 ] ; then
                        localKeyAvail=0
                fi
        fi

        # If a local key is available, check if it is already installed
        if [ $localKeyAvail -eq 0 ] ; then
                sshcopyOutput="$(ssh-copy-id -n "$login" 2>/dev/null)"
                while IFS='' read -r line
                do
                        Str__trim "$line" line                             
                        if Str__startsWith "$line" "Would have added the following key" ; then
                                remoteKeyNotInstalled=0
                                break
                        fi
                        if Str__contains "$line" "because they already exist on the remote system" ; then
                                remoteKeyNotInstalled=1
                                break
                        fi
                done <<<"$sshcopyOutput"
        fi
        
        if [ $localKeyAvail -ne 0 ] || [ $remoteKeyNotInstalled -eq 0 ] ; then
                Input__confirm "SSH auto-login seems not to be configured for '$login'. Do you want to install it?"
                if [ $? -eq 0 ] ; then
                        echo
                        if [ $localKeyAvail -ne 0 ] ; then
                                printf "\033[7mYou need first to generate an identity key. Running ssh-keygen:\033[0m\n"
                                ssh-keygen
                                # Following is commented out , because the user may choose not to overwrite the file
                                #if [ $? -ne 0 ] ; then
                                #        echo "Aborted."
                                #        return 1
                                #fi
                        fi
                        printf "\033[7mInstalling your identity key on the remote host. Running ssh-copy-id:\033[0m\n"
                        ssh-copy-id "$login"
                        if [ $? -ne 0 ] ; then
                                _log_err "Something went wrong. SSH auto login configuration aborted."
                                return 1
                        fi
                        return 0
                else
                        echo                
                        return 1
                fi
        fi
}

:<<'EOF'
mount function for SSH
@returns the return value of the mount command evaluation
EOF

Sumo__network_mount_ssh()
{
        local ret=0

        local login="${SUMO__VARS["NET_LOGIN"]}@${SUMO__VARS["NET_HOST"]}:${SUMO__VARS["NET_PATH"]}" 
        Sumo__network_handle_ssh_key_install "${SUMO__VARS["NET_LOGIN"]}@${SUMO__VARS["NET_HOST"]}"
        login=${login// /\\ }  # escape spaces

        local mountpoint="$1"

        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 

        local specificOptions="${SUMO__VARS["MOUNT_OPTIONS_SSH"]}"

        local mntcmd="sshfs "${login}" "${mntp}""
        if [ ! -z "${SUMO__VARS["PASSPHRASE"]}" ] ; then
                mntcmd="${mntcmd}<<< '${SUMO__VARS["PASSPHRASE"]}'"
        fi
        local initialOptions=""
        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                initialOptions="-o ${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi

        mntcmd="${mntcmd} ${initialOptions} ${specificOptions}"

        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
        ret=$?
        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}' with '${login}'."
        else
                _log_err "Failed to mount '${mntp}' with '${login}'."
        fi

        return $ret
}

:<<'EOF'
Unmount function for SSH
@returns the return value of the unmount command evaluation
EOF

Sumo__network_unmount_ssh()
{
        local mountpoint="$1"
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-z" ; fi
        local umntcmd="fusermount -u ${lazyOpt} "$mountpoint""
        #local umntcmd="${__SUDO__}fusermount -u ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd"
}

Sumo__network_handle_ftpserver_install()
{
        local ftpServPkg="${SUMO__VARS["FTP_SERVER_PACKAGES"]}"
        Str__replace ftpServPkg " " "
"
        _log_status high "Checking FTP server installation status on host ${SUMO__VARS["NET_HOST"]}..."
        if ! Net__checkOpenPort "ftp" "${SUMO__VARS["NET_HOST"]}"; then
                _log_status_end fail

                Term__clear
                echo

                local cfgFile
                _getConfigFilePath cfgFile                
                _log_warn "The remote FTP service seems not to be working."
                _log_high "You can install the service on the remote provided :
- Remote login via SSH is possible on host ${SUMO__VARS["NET_HOST"]}
- user '${SUMO__VARS["NET_LOGIN"]}' is defined on host ${SUMO__VARS["NET_HOST"]}
- user '${SUMO__VARS["NET_LOGIN"]}' is a sudoer's
- NOTE: you can choose another login by either specifying --user|-U option or specifying login inside the FTP URL
"
                Input__cursorSelect "${ftpServPkg}" "${_pal['bg_blue']}Select FTP server to install or abort with 'q':${Term__reset_color}" 1
                local key=$?
                Term__restoreCursor
                if [ $key -eq 0 ] ; then
                        echo
                        _exit -1 "FTP mount aborted."

                fi
                local pkg="$(echo "${ftpServPkg}"| head -n $key | tail -n1)" # This enables to manage value containing spaces
                _log
                _log_status high "Installing APT package ${pkg}..."
                _log
                if ! APT__distant_install "$pkg" "" "${SUMO__VARS["NET_LOGIN"]}" "${SUMO__VARS["NET_IP"]}" ; then
                        _log_status_end fail
                        _exit -1 "Failed to install APT package ${ftpServPkg} on remote host. FTP mount aborted."
                fi
:<<'EOF'
                local cmd="plink -X ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} 'dpkg-query -l \"${pkgNfsServ}\" &>/dev/null && [[ \$(dpkg-query -W -f='\''\${db:Status-Abbrev}'\'' \"${pkgNfsServ}\") =~ ^ii ]] || sudo DEBIAN_FRONTEND=\"noninteractive\" apt install ${pkgNfsServ} -y || echo NOPE' <<<''"
                _logf "COMMAND: '$cmd'"
                local testInstalled="$(eval "$cmd")"
                Str__trim "$testInstalled" testInstalled
                #_log_vars testInstalled
                if Str__endsWith "$testInstalled" "NOPE" ; then
                        _log_status_end fail
                        _exit -1 "Failed to install APT package nfs-kernel-server on remote host. NFS mount aborted."
                fi
EOF
                _log_status_end ok
        else
                _log_status_end ok
        fi
}

Sumo__network_handle_ftppass_install()
{
        local netrcPath="$HOME/.netrc"
        local netrcPathBackup="$HOME/.netrc_sumo_backup"
        local netrcSpecificPath="$HOME/.netrc_${SUMO__VARS["NET_HOST"]}"
        # (Re)build netrc if file does not exist or there'is an explicit password
        if [ ! -f "${netrcSpecificPath}" ] || [ ! -z "${SUMO__VARS["PASSPHRASE"]}" ]  ; then 
                if [ -z "${SUMO__VARS["NET_LOGIN"]}" ] ; then
                        _log_warn "You must provide a user. It will be stored in ${netrcPath}."
                        _log "You can either rerun command with --user option or enter it now below."
                        local __login
                        read -r -p "Enter login: " __login 2>&1
                        SUMO__VARS["NET_LOGIN"]="${__login}"
                else
                        _log_high "Using login '${SUMO__VARS["NET_LOGIN"]}'"
                fi

                if [ -z "${SUMO__VARS["PASSPHRASE"]}" ] ; then
                        _log_warn "You must provide a password. It will be stored in ${netrcPath}."
                        _log "You can either rerun command with -p option or enter it now below."
                        local __ftppass
                        Input__password __ftppass
                        SUMO__VARS["PASSPHRASE"]="${__ftppass}"
                        #_log "pass '$__ftppass'"
                        #return 1
                fi
                echo "machine ${SUMO__VARS["NET_HOST"]}" > "${netrcSpecificPath}"  
                echo "login ${SUMO__VARS["NET_LOGIN"]}" >> "${netrcSpecificPath}"  
                echo "password ${SUMO__VARS["PASSPHRASE"]}" >> "${netrcSpecificPath}"  

                local cmd="${__SUDO__}chown \"$(id -u):$(id -g)\"  \"${netrcSpecificPath}\""
                eval "$cmd"
                chmod 600 "${netrcSpecificPath}"                
        fi

        if [ -f "${netrcPath}" ] ; then 
                mv "${netrcPath}" "${netrcPathBackup}"
        else
                cp "${netrcSpecificPath}" "${netrcPathBackup}" 
        fi
        #echo ln -s "${netrcSpecificPath}" "${netrcPath}" 
        cp -f "${netrcSpecificPath}" "${netrcPath}" 
        #echo $?
}

:<<'EOF'
mount function for FTP
@returns the return value of the mount command evaluation
EOF

Sumo__network_mount_ftp()
{
        Input__clearForcedInput

        Sumo__network_handle_ftpserver_install 

        local ret=0

        local login="${SUMO__VARS["NET_LOGIN"]}@${SUMO__VARS["NET_HOST"]}" 
        login=${login// /\\ }  # escape spaces
        Sumo__network_handle_ftppass_install 
        if [ $? -ne 0 ] ; then return 1; fi

        local mountpoint="$1"

        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 

        local specificOptions="${SUMO__VARS["MOUNT_OPTIONS_FTP"]}"

        if [ ! -z "${SUMO__VARS["NET_PORT"]}" ] ; then
                specificOptions="$specificOptions -o ftp_port=${SUMO__VARS["NET_PORT"]}"
        fi
        #local mntcmd="curlftpfs "${login}" "${mntp}""
        local initialOptions="-o uid=$(id -u) -o gid=$(id -g)"
        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                initialOptions="${initialOptions} -o ${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi

        local mntcmd="curlftpfs ${initialOptions} ${specificOptions} ${login} ${mntp}"
        local netrcPath="$HOME/.netrc"

        #_logf "MOUNT COMMAND (as $(id -u)): $mntcmd"
        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
        ret=$?
        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}' with 'ftp://${login}'."
        else
                _log_err "Failed to mount '${mntp}' with '${login}'. '$netrcPath' was removed."
                #_log_err "Failed to mount '${mntp}' with '${login}'. Check content of file '$netrcPath' : $(cat "$netrcPath")"
                # Remove the netrc file
                local netrcSpecificPath="$HOME/.netrc_${SUMO__VARS["NET_HOST"]}"
                rm "${netrcSpecificPath}" &> /dev/null
        fi

        #local netrcPathBackup="$HOME/.netrc_sumo_backup"
        #rm "${netrcPath}" 
        #mv "$HOME/.netrc_sumo_backup" "${netrcPath}" 
        return $ret
}

:<<'EOF'
Unmount function for SSH
@returns the return value of the unmount command evaluation
EOF

Sumo__network_unmount_ftp()
{
        local mountpoint="$1"
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-z" ; fi
        #local umntcmd="${__SUDO__}fusermount -u ${lazyOpt} "$mountpoint"" # with sudo
        local umntcmd="fusermount -u ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd"
}


Sumo__network__nfs_resolveRemoteUser()
{
        local remoteUser="${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}"
        if [ -z "${remoteUser}" ] ; then
                local remoteUser=""
                Input__Word "Please enter remote login for NFS server configuration:" "${remoteUser}" remoteUser
                SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]="${remoteUser}"
        fi
}

Sumo__network_handle_nfsserver_install()
{
        _log_status high "Checking NFS server installation status on host ${SUMO__VARS["NET_HOST"]}..."
        if ! Net__checkOpenPort "nfs" "${SUMO__VARS["NET_HOST"]}" ; then
                _log_status_end fail

                Sumo__network__nfs_resolveRemoteUser
                echo
                local cfgFile
                _getConfigFilePath cfgFile                
                _log_warn "The remote NFS service seems not to be working."
                _log_high "You can install the service on the remote provided :
- user '${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}' is defined on host ${SUMO__VARS["NET_HOST"]}
- user '${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}' is a sudoer's
- Note: you can defined the default user login to use in cfg file '$cfgFile' by defining property 'nfs remote server login'
".
                Input__confirm "Continue and attempt to install NFS server out there?"
                echo

                if [ $? -ne 0 ] ; then
                        _exit -1 "NFS mount aborted."
                fi

                _loadDep "openssh-client"               # requires ssh

                ################################
                ## Testing if already installed
                local pkgNfsServ="nfs-kernel-server"

                _log_status high "Testing if APT package ${pkgNfsServ} is installed..."
                _log ""
                local cmd="$(cat << EOF 
ssh ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} '(dpkg-query -l "${pkgNfsServ}" &>/dev/null && ! test -z "\$(dpkg-query -W -f='\${db:Status-Abbrev}' "${pkgNfsServ}"|grep -E ^ii)")
EOF
)"
                _logf "COMMAND: '$cmd'"
                eval "$cmd" 2>/dev/null
                if [ $? -eq 0 ] ; then
                        _log_status_end ok
                else
                        _log_status high "Installing APT package ${pkgNfsServ}..."
                        _log ""
                        local cmd="$(cat << EOF 
ssh ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} -t 'sudo DEBIAN_FRONTEND="noninteractive" -S apt install ${pkgNfsServ}'
EOF
)"
                        _logf "COMMAND: '$cmd'"
                        eval "$cmd" 2>/dev/null
                        if [ $? -ne 0 ] ; then
                                _log_status_end fail
                                _exit -1 "Failed to install APT package nfs-kernel-server on remote host. NFS mount aborted."
                        fi
                        _log_status_end ok
                fi
        else
                _log_status_end ok
        fi

        #exit 0
}

:<<'EOF'
mount function for NFS
@returns the return value of the mount command evaluation
EOF

Sumo__network_mount_nfs()
{        
        Sumo__network_handle_nfsserver_install 

        if [ -x /etc/init.d/rpcbind ] ; then
                ${__SUDO__}/etc/init.d/rpcbind status &>/dev/null
                if [ $? -ne 0 ] ; then
                        _log_high "Starting rpcbind"
                        ${__SUDO__}/etc/init.d/rpcbind restart &>/dev/null
                fi
        fi

        local ret=0

        if [ $? -ne 0 ] ; then return 1; fi

        local mountpoint="$1"

        local mntp="${SUMO__VARS["MOUNT_POINT"]}" 
        local specificOptions="${SUMO__VARS["MOUNT_OPTIONS_NFS"]}"
        local initialOptions=""
        if [ ! -z "${SUMO__VARS["MOUNT_OPTIONS"]}" ] ; then
                initialOptions="-o ${SUMO__VARS["MOUNT_OPTIONS"]}"
        fi
        local mntAddr="${SUMO__VARS["NET_HOST"]}:${SUMO__VARS["NET_PATH"]}" # SUMO__VARS["DEVPART"]?
        local mntcmd="${__SUDO__}mount ${initialOptions} ${specificOptions} "${mntAddr}" ${mntp}"

        _logf "MOUNT COMMAND: $mntcmd"
        eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
        ret=$?
        if [ $ret -eq 0 ] ; then
                _log "Successfully mounted '${mntp}' with '${mntAddr}'."
        else
                _log_warn "Failed to mount '${mntp}' with '${mntAddr}'."
                Sumo__network_handle_nfs_exports                

                # Try again then
                sleep 1
                eval "$mntcmd" 2>>"${__LOG_ERR_FILE__}"
                ret=$?
                if [ $ret -eq 0 ] ; then
                        _log "Successfully mounted '${mntp}' with '${mntAddr}'."
                else
                        local _errlog
                        _getLogErrPath _errlog
                        _log_err "Failed to mount '${mntp}' with '${mntAddr}'. Please check log '$_errlog' file for details."
                        ret=1
                fi

                #cmd="plink -X ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} 'dpkg-query -l \"${pkgNfsServ}\" &>/dev/null && [[ \$(dpkg-query -W -f='\''\${db:Status-Abbrev}'\'' \"${pkgNfsServ}\") =~ ^ii ]] || sudo DEBIAN_FRONTEND=\"noninteractive\" apt install ${pkgNfsServ} -y || echo NOPE' <<<''"
                #_logf "COMMAND: '$cmd'"

        fi
        return $ret
}

Sumo__network_handle_nfs_exports()
{
        local netPathRaw="${SUMO__VARS["NET_PATH"]}"
        local netPath="${netPathRaw}"
        netPath="${netPath//\//\\\/}"
        local myIP
        local myHostname="$(hostname)"

        Net__resolve "$myHostname" myIP myHostname
        if [ $? -ne 0 ] ; then
                _log_warn "Failed to resolve local IP from hostname '${myHostname}'. Trying hostname -I."
                 Net__getHostIP myIP
                if [ $? -ne 0 ] ; then
                        _exit -191 "Impossible to proceed further. Aborted."
                        return 1
                fi
                _log "Found IP ${myIP}"
        fi

        Sumo__network__nfs_resolveRemoteUser

        _log ""
        _log ""
        _log_status high "Checking NFS exports ${SUMO__VARS["NET_HOST"]}..."
        _log ""

        _loadDep "openssh-client"               # requires ssh

        local checkExportCmd="$(cat << EOF 
sudo -S cat /etc/exports | awk '/^${netPath} ${myHostname}/{print \"OK\"} /^${netPath} ${myIP}/{print \"OK\"}'
EOF
)"
        local cmd="ssh ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} \"${checkExportCmd}\""
        #echo "$checkExportCmd"
        #echo "$cmd"
        _logf "COMMAND: '$cmd'"
        read resCmd < <(eval "$cmd")
        if [[ "$resCmd" =~ "OK"$ ]] ; then
                _log_status_end ok
                _log_warn "The /etc/exports file on the distant host seems to be OK. Please check the issue directly on the host or with the admnistrator."
        else
                _log_status_end fail
                local exportOptions="${SUMO__VARS["NFS_EXPORTS_OPTIONS"]}"
                _log_high "Attempting to update the distant /etc/exports file with the following lines."
                _log "     ${netPathRaw} ${myHostname}(${exportOptions}"
                _log "     ${netPathRaw} ${myIP}(${exportOptions}"
                if ! Input__confirm "Continue?" ; then
                        _log ""
                        _exit -1 "Mount aborted."
                fi

                _log ""
                _log_status high "Updating the distant /etc/exports file..."
                local addExportsCmd="$(cat << EOF 
(sudo chmod og+w /etc/exports) && (sudo echo "${netPathRaw} ${myHostname}(${exportOptions})" >> /etc/exports) && (sudo echo "${netPathRaw} ${myIP}(${exportOptions})" >> /etc/exports) && (sudo chmod og-w /etc/exports) && (sudo exportfs -ra || echo 'exportfs issues some warnings')
EOF
)"
                #sudo cat /etc/exports | uniq > /tmp/exports && sudo mv /tmp/exports /etc/exports && echo OK
                cmd="ssh ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} -t '${addExportsCmd}'"
                _logf "COMMAND: '$cmd'"
                eval "$cmd"
                if [ $? -eq 0 ] ; then
                        _log_status_end ok
                        local checkUserIdCmd="$(cat << EOF 
                        stat -c '%u' ${netPathRaw}
EOF
)"
                        cmd="ssh ${SUMO__VARS["NFS_REMOTE_SERVER_LOGIN"]}@${SUMO__VARS["NET_HOST"]} '$checkUserIdCmd'"
                        _logf "COMMAND: '$cmd'"
                        local distantUID="$(eval "$cmd")"
                        if [ $? -eq 0 ] ; then
                                local ownUID="$(id -u)"

                                if [ "$distantUID" != "$ownUID" ] ; then
                                        local helpMsg="$(cat << EOF 

        You may not have full access to the mounted folder.
        You may fix this in any of the following way:

        1. Changing your local user ID using 'sudo usermode $USER -u $distantUID'. 
           Requires logout and change made from another account
           May be sufficient for domestic uses

        2. Changing the distance user ID using 'sudo usermode $USER -u $ownUID'. 
           Requires logout and change made from another account
           May be sufficient for domestic uses

        3. Define a user mapping using 'nfsidmap'. Execute 'man nfsidmap' 
           Requires modifying map file '/etc/idmapd.conf' and '/etc/request-key.conf'
           Highly recommended for professional and public uses.

        4. Setup Kerberos and switch NFS to 'sec=krb5'
           Highly recommended when using NFS over the Internet.

EOF
)"                                
                                        _log_warn "The owner ID of the distant path '${netPathRaw}' is ${distantUID}, whereas yours is ${ownUID}. "
                                        _log "$helpMsg"
                                fi
                        fi 
                else
                        _log_status_end fail
                        _exit -1 "Mount aborted due to the above failures."
                fi
        fi
}

:<<'EOF'
Unmount function for SSH
@returns the return value of the unmount command evaluation
EOF

Sumo__network_unmount_nfs()
{
        local mountpoint="$1"
        local lazyOpt=""
        if [ "${SUMO__VARS["LAZY"]}" == "lazy" ] ; then lazyOpt="-l" ; fi
        local umntcmd="${__SUDO__}umount ${lazyOpt} "$mountpoint""
        _logf "UMOUNT COMMAND: $umntcmd"
        eval "$umntcmd"
}

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
# Release file path: sumo__virt.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-06 18:25:08.479355192 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to mounting/unmounting of virtual machine disk files
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

#nbd-client Not needed at the moment
#Sumo__virt_nbdClientPkg="nbd-client" # "nbd-client -d /dev/nbd0"
Sumo__virt_qemuPkg="qemu-utils" 
Sumo__virt_isInstalled() 
{
        if ! APT__isInstalled "${Sumo__virt_qemuPkg}"; then
                _log_err "Package '$Sumo__virt_qemuPkg' is not installed."
                return 1
:<<'EOF'
        elif ! APT__isInstalled "${Sumo__virt_nbdClientPkg}"; then
                _log_warn "Package '$Sumo__virt_nbdClientPkg' is not installed. It may not be possible to cleanup the nbd devices like /dev/nbd0."
                return 1
EOF
        else
                return 0
        fi
}

:<<'EOF'
This function is the subroutine dedicated to the loading of the dependencies for
virtual machine disk files .
It is up to the calling routine to call this one at the proper time.
EOF

Sumo__virt_loadDep() 
{
    local depName="$1"
    local installOptions=""
    if [ -v __REFRESH_DEPS__ ] ; then
            installOptions="--reinstall"
    fi
    Pkg__install "${Sumo__virt_qemuPkg}" "" apt "" "${installOptions}" > /dev/null

    # kmod for modprobe
    Pkg__install "kmod" "" apt "" "${installOptions}" > /dev/null
    #nbd-client
    #Pkg__install "${Sumo__virt_nbdClientPkg}" "" apt "" "${installOptions}" > /dev/null
}

:<<'EOF'
This function indicates whether internal variables and data are referring to a virtual machine
disk image.
- Not a block device, image is a file, file extension is one of the virtual disk extensions
EOF

Sumo__isVirt() {
        if ! Sumo__isDiskFile ; then
                return 1
        fi

        if Array__contains_by_string "${SUMO__VARS["VIRTDISK_EXTENSIONS"]}" "${SUMO__VARS["IMG_TYPE"]}"; then
                return 0
        fi

        local fileExt
        File__ext "${SUMO__VARS["IMG_FILE"]}" fileExt
        Str__toLower fileExt
        if  Array__contains_by_string "${SUMO__VARS["VIRTDISK_EXTENSIONS"]}" "$fileExt" ; then
                return 0
        fi

        if Str__startsWith "${SUMO__VARS["DEV"]}" "/dev/nbd" ; then
                return 0
        fi

        return 1
}

:<<EOF
This function is in charge of managing the creation of virtual machine disk files depending 
on the specified file argument and configured creation options. 

If no size was defined by option, the user is prompted to enter one.
EOF

Sumo__virt_createDiskFile()
{
    File__ext "${SUMO__VARS["IMG_FILE"]}" fileExt
    Str__toLower fileExt
    Sumo__virt_createDiskFileFromExtension "${fileExt}"
}


:<<EOF

This function is in charge of managing the creation of qcow2 disk files.
Disk file of name given by SUMO__VARS["IMG_FILE"] is created with 'qemu-img' too according to the requested size given by option SUMO__CREATION_OPTIONS[size].
If no size was defined by option, the user is prompted to enter one.

sgdisk is called upon SUMO__VARS["IMG_FILE"] to create and format a single Linux partition on the disk (type 8300)

EOF
Sumo__virt_createDiskFileFromExtension()
{        
        if ! Sumo__virt_isInstalled ; then
             return 1
        fi
        local diskFileExtension="$1";

        # Manage disk creation on request
        local memsize=0
        local memunit=""
        local qemu_memunit=""

        Input__pushForcedInput "${SUMO__CREATION_OPTIONS[size]}"
        Input__memsize "Please enter disk size K=Kilobytes, M=Megabytes, G=Gigabytes, T=Terabytes" memsize memunit raw
        
        if [ $? -ne 0 ] ; then
                _exit -1 "Aborted disk creation."
        fi
        
        case "$memunit" in
                k|m|g|t) qemu_memunit="$memunit" ; Str__toUpper qemu_memunit ;;
                *) _exit -2 "unsupported memory size unit '$memunit' returned by Input__memsize" ;;
        esac

        _log "Creating VM disk image ${SUMO__VARS["IMG_FILE"]} of size ${memsize}${qemu_memunit}, file system type ${SUMO__VARS["FS_TYPE"]}"
        local creationcmd="qemu-img create -f ${diskFileExtension} ${SUMO__VARS["IMG_FILE"]} ${memsize}${qemu_memunit}"
        _logf "${diskFileExtension} CREATION COMMAND: $creationcmd"

        eval "$creationcmd"
        if  [ $? -eq 0 ]; then
                _log "Disk file ${SUMO__VARS["IMG_FILE"]} was successfully created."
                local diskBlockDevice
                if Sumo__virt_nbd_open "${SUMO__VARS["IMG_FILE"]}" ${SUMO__VARS["IMG_TYPE"]} diskBlockDevice ; then 
                        local createPartRet
                        Dev__createSinglePartition "$diskBlockDevice" "${SUMO__VARS["FS_TYPE"]}" 0 
                        createPartRet=$?
                        Sumo__virt_nbd_close "${diskBlockDevice}"
                        return $createPartRet
                else
                        return 1
                fi
        else
                return 1
        fi
}

:<<'EOF'
Main mount function for virtual machine disk files
EOF

Sumo__virt_mount()
{
    if Env__fn_exists "Sumo__virt_mount_${SUMO__VARS["IMG_TYPE"]}" ; then
        Sumo__virt_mount_${SUMO__VARS["IMG_TYPE"]}

        if [ $? -eq 0 ] ; then
                : # Sumo__updateSavedRecentList "${SUMO__VARS["DEVPART"]}" "${SUMO__VARS["MOUNT_POINT"]} " "" "mount"
        fi

    else
        _log_err "Internal error: Sumo__virt_mount_${SUMO__VARS["IMG_TYPE"]} called for file extension ${fileExt} whereas this code should never have been reached."
    fi        
}

:<<'EOF'
Main  unmount function for virtual machine disk files
EOF

Sumo__virt_unmount()
{
        if Env__fn_exists "Sumo__virt_unmount_${SUMO__VARS["IMG_TYPE"]}" ; then
                Sumo__virt_unmount_${SUMO__VARS["IMG_TYPE"]}
        else
                _log_err "Internal error: Sumo__virt_unmount_${SUMO__VARS["IMG_TYPE"]} called for file extension ${fileExt} whereas this code should never have been reached."
        fi        
}

Sumo__virt_nbd_open()
{
        local diskFileName="$1"
        local diskType="$2"
        local -n out_diskBlockDevice=$3
        ${__SUDO__}modprobe nbd
        local nextNbdAvailable=0
        local retEval=0
        local cmd="${__SUDO__}qemu-nbd -c /dev/nbd${nextNbdAvailable} \"$diskFileName\" -f \"$diskType\""  # --read-only 
        _logf "NBD connect COMMAND: $cmd"
        eval "$cmd" 2> /dev/null
        retEval=$?
        while [ $retEval -ne 0 ] ; do
                if [ $nextNbdAvailable -ge 256 ] ; then # Mostly probably there is anywrong wrong nbd
                        return 1
                fi
                nextNbdAvailable=$(($nextNbdAvailable + 1))
                cmd="${__SUDO__}qemu-nbd -c /dev/nbd${nextNbdAvailable} \"${diskFileName}\" -f \"${diskType}\""  # --export-name=\"${SUMO__VARS["FS_LABEL"]}\""
                _logf "NBD connect COMMAND: $cmd"
                sleep 1 # remove later
                eval "$cmd" &>>"${__LOG_ERR_FILE__}"
                retEval=$?
                if [ $retEval -ne 0 ] ; then
                        _logf "NBD connect COMMAND failed with error code $retEval"
                fi
        done

        _log_dbg "My device is /dev/nbd${nextNbdAvailable}"
        out_diskBlockDevice="/dev/nbd${nextNbdAvailable}"
}

Sumo__virt_nbd_close()
{        
        local diskDevice="$1"
        local cmd="${__SUDO__}qemu-nbd --disconnect \"${diskDevice}\""
        _logf "NBD disconnect COMMAND: $cmd"
        eval "$cmd" &>> "${__LOG_ERR_FILE__}"
}


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
# Release file path: sumo__luks.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-12-17 19:09:56.054476465 +0000
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

Sumo__luks_isInstalled() 
{
    local pkg="cryptsetup-bin"    
        if ! APT__isInstalled "$pkg"; then
                _log_warn "Package '$pkg' is not installed."
                return 1
        else
                return 0
        fi
}

:<<'EOF'
This function is the subroutine dedicated to the loading of the dependencies for luks.
It is up to the calling routine to call this one at the proper time.
EOF

Sumo__luks_loadDep() 
{
    local pkg="luks"    
    local installOptions=""
    if [ "$depName" == "luks" ] || [ "$depName" == "all" ] ; then
        if [ -v __REFRESH_DEPS__ ] ; then
            installOptions="--reinstall"
        fi
        Pkg__install "${pkg}" "" apt "" "${installOptions}" > /dev/null
    fi
}


:<<'EOF'
Indicates whether the input given for mount/unmount was a LUKS disk file or not. 
This function shall be called only after the argument parsing using __parseArgs
@returns 0 when true, 1 otherwise
EOF

Sumo__isLuks() {       
        if ! Sumo__isDiskFile ; then
                return 1
        fi

        if [ "${SUMO__VARS["IMG_TYPE"]}" == "luks" ] ; then
                return 0
        fi

        local fileExt
        File__ext "${SUMO__VARS["IMG_FILE"]}" fileExt
        Str__toLower fileExt
        if Array__contains_by_string "${SUMO__VARS["LUKS_EXTENSIONS"]}" "$fileExt" ; then
                return 0
        fi

:<<'EOF'
    #Currently only disk files are fully supported something equivalent may be needed later for it 
        if Str__startsWith "${SUMO__VARS["DEV"]}" "/dev/nbd" ; then
                return 0
        fi
EOF

        return 1
}

:<<EOF
@param[1] device
@param[2] passphrase
EOF
Sumo__luks_format() {
    local currentDevice="$1"
    local passphrase="$2"
    local lukscmd="${__SUDO__} cryptsetup luksFormat \"$currentDevice\""
    if [ ! -z "$passphrase" ] ; then
            lukscmd="${lukscmd} <<<\"$passphrase\""  # > /dev/null # Setup the Luks partition
            cryptopen_res=$?
    fi
    _logf "LUKS COMMAND: $lukscmd"
    eval "$lukscmd" 2>>"${__LOG_ERR_FILE__}"
}


:<<EOF
This function is in charge of managing the creation of virtual machine disk files depending 
on the specified file argument and configured creation options. 

If no size was defined by option, the user is prompted to enter one.
EOF

#Sumo__luks_createDiskFile()


:<<'EOF'
Mmount wrapper function for LUKS

@param [1] Device to mount is expected 
@param [2] Device label (Luks logical name)
@param [3] Mount options
@param [4] The device mapper if opening was succesful
EOF

Sumo__luks_open()
{
    local currentDevice="$1"
    local label="$2"
    local -n __out_devicemapper=$3
    local passphrase="$4"
    local res=1

    if [ "$passphrase" = "-" ] ; then
        passphrase=""
    fi

    if [ "$label" = "-" ] ; then
        File__basename "$currentDevice" label
    fi

    # Attempt to silently close luks should have been opened before for any reason before
    # it could be mounted.
    local lukscmd="${__SUDO__}cryptsetup -v close \"${label}\""
    eval "$lukscmd" &> /dev/null 

    # Opens Luks partition. This will open a device mapper to be used to access encrypted data
    _log_dbg "cryptsetup open dev='$currentDevice', passphrase:'${passphrase}'"
    lukscmd="${__SUDO__}cryptsetup open --type luks \"$currentDevice\" \"${label}\""
    if [ -z "${passphrase}" ] ; then
            lukscmd="${lukscmd}" # > /dev/null 
    else
            lukscmd="${lukscmd} <<<\"${passphrase}\"" 
    fi
    _logf "LUKS COMMAND: $lukscmd"
    eval "$lukscmd" 2>>"${__LOG_ERR_FILE__}"
    res=$?

    if [ ${res} -eq 0 ] ; then
            _log "Successfully opened LUKS device with label '$label'."
    else
            _log_err "Failed opened LUKS device '$currentDevice' with label '$label'. Return value was ${res}."
            return 1
    fi

    Dev__getDeviceMapper "$label" "/dev/mapper/" ${!__out_devicemapper} 

    return $res
}

Sumo__luks_close()
{
    local currentDevice="$1"
    local label="$2"

    if [ -z "$label" ] ; then
        File__basename "$currentDevice" label
    fi
    ${__SUDO__}cryptsetup -v close "${label}" &>>"${__LOG_ERR_FILE__}" 
    if [ $? -ne 0 ] ; then
            _log_warn "Failed to close LUKS device with label '$label'."
            return 1
    fi
    return 0
}


:<<'EOF'
Main  unmount function for virtual machine disk files

Sumo__luks_unmount()
{
        if Env__fn_exists "Sumo__luks_unmount_${SUMO__VARS["IMG_TYPE"]}" ; then
                Sumo__luks_unmount_${SUMO__VARS["IMG_TYPE"]}
        else
                _log_err "Internal error: Sumo__luks_unmount_${SUMO__VARS["IMG_TYPE"]} called for file extension ${fileExt} whereas this code should never have been reached."
        fi        
}
EOF


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
# Release file path: sumo__vera.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-08 12:15:11.140284533 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to mounting/unmounting of VERA volumes
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

Sumo__vera_isInstalled() 
{
        local veraPackage="veracrypt-console"
        if ! DPKG__isInstalled "$veraPackage"; then
                _log_warn "VERA Debian package '$veraPackage' is not installed."
                return 1
        else
                return 0
        fi
}

:<<'EOF'
This function is the subroutine dedicated to the loading of the VERA dependencies.
It is up to the calling routine to call this one at the proper time.
EOF

Sumo__vera_loadDep() 
{
        local installOptions=""
        if [ -v __REFRESH_DEPS__ ] ; then
                installOptions="--reinstall"
                unset __REFRESH_DEPS__ # to avoid multiple reinstallation
        fi
        local distroname="$(Env__distroname)"
        Str__toUpper distroname
        local URL=""
        local downloadURLParam="VERA_DOWNLOAD_URL_${distroname}"
        if [ ! -z "${SUMO__VARS["$downloadURLParam"]}" ] ; then
                URL="${SUMO__VARS["$downloadURLParam"]}"
        fi
        Pkg__install "sudo" "" apt 
        Pkg__install "libpcsclite1" "" apt 
        Pkg__install "pcscd" "" apt 
        Pkg__install "libfuse2" "" apt 
        Pkg__install "xxd" "" apt                       # For random number used by Str__randomWord
        _log_dbg "URL: '$distroname'  '$URL'"
        if [ -z "${URL}" ] ; then
                _log_err "No download URL defined for VERA. Please define the following parameter based an existing configs:"
                Str__toLower downloadURLParam
                downloadURLParam="${downloadURLParam//_/ }"
                _log_high "${downloadURLParam}"
                return 1
        else
                # Try out different version starting from the latest
                local veraVersions=(${SUMO__VARS["VERA_VERSION"]})
                local veraVer
                local veraVerFound=false
                for veraVer in "${veraVersions[@]}" ; do
                        if Pkg__install "veracrypt-console" "${veraVer}" dpkg "$URL" "${installOptions}"  ; then
                                veraVerFound=true
                                break
                        fi
                done
                if $veraVerFound ; then return 0; else return 1; fi
        fi
}

:<<'EOF'
This function indicates whether internal variables and data are referring to a VERA volume:
- Not a block device, image is a file, file extension is one of the VERA supported extensions
- Device path points to /dev/mapper/veracrypt
- The label is a numeric value.
EOF

Sumo__isVera() {
    File__ext "${SUMO__VARS["IMG_FILE"]}" fileExt
    Str__toLower fileExt
    _log_dbg "Sumo__isVera blkdev:${SUMO__VARS["IMG_FILE_IS_BLK_DEV"]} file= '${SUMO__VARS["IMG_FILE"]}' ext='$fileExt' extension:'${SUMO__VARS["SUMO__VERA_EXTENSIONS"]}' image type '${SUMO__VARS["IMG_TYPE"]}'"
    if [ ${SUMO__VARS["IMG_FILE_IS_BLK_DEV"]} -ne 0 ] && [ ! -z "${SUMO__VARS["IMG_FILE"]}" ] && Array__contains_by_string "${SUMO__VARS["SUMO__VERA_EXTENSIONS"]}" "$fileExt" ; then
_log_dbg "Sumo__isVera IS VERA!!!!"
            return 0
    fi

    if Array__contains_by_string "${SUMO__VARS["SUMO__VERA_EXTENSIONS"]}" "${SUMO__VARS["IMG_TYPE"]}"; then
            return 0
    fi

    if Str__startsWith "${SUMO__VARS["DEVPART"]}" "/dev/mapper/veracrypt" ; then
            return 0
    fi

    if [ ! -z "${SUMO__VARS["FS_LABEL"]}" ] && Int__isInt "${SUMO__VARS["FS_LABEL"]}" ; then
            return 0
    fi

    return 1
}

:<<'EOF'
This function is in charge of resolving  indicates whether internal variables and data are referring to a VERA volume.

@param [1] label, i.e. a slot number for VERA.
@output SUMO__VARS["MOUNTED"] is set to 0 if a volume of that slot number is mounted.
EOF

Sumo__vera_determineIfLabelIsMounted() 
{
    local slotNbr="$1"
    if veracrypt -l --slot "$slotNbr" &>/dev/null; then
            SUMO__VARS["MOUNTED"]=0
            return 0
    else
            # Nothing found is just fine at creation of a new image. Only relevant
            # when attempting to open an existing image
            if [ ${SUMO__VARS["CREATE_FILE"]} -ne 0 ] ; then
                    _quit "No vera volume found with slot '$slotNbr'"
            fi
            return 1
    fi
}

# NOTE: Sumo__resolveMountingInfosFromDiskFile is used to resolve mountings infos


:<<EOF
This function is in charge of managing the creation of VERA disk files depending 
on the specified file argument and configured creation options. 

If no size was defined by option, the user is prompted to enter one.
@param[1] file
@param[2] type of filesystem to be encrypted
@param[3] optional passphrase
EOF

Sumo__vera_createDiskFile()
{
        if ! Sumo__vera_isInstalled ; then
                return 1
        fi

        local verafile="$1"
        local fstype="$2"
        local passphrase="$3"
        
        # Manage disk creation on request
        local veracmd
        local verasizeoption=""
        local memsize=0
        local memunit=""
        local vera_memunit=""

        # Ask for a size only if VERA volume is a file
        # For device-hosted volumes, the whole device size is used by default
        if [ "${SUMO__VARS["IMG_FILE_IS_BLK_DEV"]}" -ne 0 ] ; then
                Input__pushForcedInput "${SUMO__CREATION_OPTIONS[size]}"
                Input__memsize "Please enter disk size" memsize memunit raw
                
                if [ $? -ne 0 ] ; then
                        _exit -1 "Aborted disk creation."
                fi
                case "$memunit" in
                        k) vera_memunit="KiB";;
                        m) vera_memunit="MiB";;
                        g) vera_memunit="GiB";;
                        t) vera_memunit="TiB";;
                        *) _exit -2 "unsupported memory size unit '$memunit' returned by Input__memsize" ;;
                esac

                verasizeoption="--size=${memsize}${vera_memunit}"
        fi

        _log "Creating random source ..."
        local randomsource="$(mktemp)" #"${verafile}_randomsdata.txt"
        
        # Inside docker dmesg is not available, use a methd based on xxd
        #dmesg > $randomsource
        Str__randomWord 1000 > "$randomsource"

        _log "Creating disk image ${verafile} of size ${memsize}${vera_memunit}, file system type ${fstype}"
        #_exit 0
        # -size=SIZE[K|KiB|M|MiB|G|GiB|T|TiB]
        veracmd="veracrypt -t -c \
        ${verasizeoption} \
        --filesystem="${fstype}" \
        --random-source "$randomsource" \
        ${SUMO__VARS["VERA_CREATION_OPTIONS"]}"
        
        if [ ! -z "${passphrase}" ] ; then
                veracmd="$veracmd -p ${passphrase}"
        fi
        #if [ ! -z "${mountoptions}" ] ; then
        #        veracmd="$veracmd -m ${mountoptions}"
        #fi

        veracmd="$veracmd \"${verafile}\""
        _logf "VERA CREATION COMMAND: $veracmd"

        eval "$veracmd"
        cryptopen_res=$?
        rm -f "$randomsource"
        if [ ${cryptopen_res} -eq 0 ] ; then
                _log "Disk file ${verafile} was successfully created."
                return 0
        else
                return 1
        fi
}

:<<'EOF'
Manages mounting and creation for Vera volumes
PIM is just the number of iteration an hash is recomputed to encrypt/decrypt data. 
It slows down by as many time the time to hack the volume, but also the access times
It is more efficient to add a password char.
See https://www.reddit.com/r/VeraCrypt/comments/yvi1ul/could_someone_please_explain_what_a_pim/
EOF

Sumo__vera_mount()
{
        if ! Sumo__vera_isInstalled ; then
                return 1
        fi

        local verafile="$1"
        local mountpoint="$2"
        local label="$3"
        local passphrase="$4"

        SUMO__CURRENT_OPERATION="mount"

        if [ ! -v SHELL_API_DEP_LOADED["vera"] ] ; then
                _exit -1 "Sorry, the package(s) to support VERA are not available or could not be installed. VERA voluments are no supported."
        fi

        # The rw option does not exist for VERA
        local mountoptions=""
        Str__trimStart "${SUMO__VARS["MOUNT_OPTIONS"]}" mountoptions "rw"
        Str__trimStart "${mountoptions}" mountoptions ","

        # Handle the vera stuff
        local cryptopen_res=0
        local veracmd

        veracmd="veracrypt -t -k \"\" --pim=0 --protect-hidden=no \"${verafile}\" \"${mountpoint}\""
        if [ ! -z "${label}" ] && [ "${label}" != "-" ] ; then
                veracmd="$veracmd --slot ${label}"
        fi

        if [ ! -z "${passphrase}" ] ; then
                veracmd="$veracmd -p \"${passphrase}\""
        fi

        if [ ! -z "${mountoptions}" ] ; then
                veracmd="$veracmd -m ${mountoptions}"
        fi

        _logf "VERA MOUNT COMMAND: $veracmd"

        eval "$veracmd"
        cryptopen_res=$?
        if [ ${cryptopen_res} -eq 0 ] ; then
                if [ ${SUMO__VARS["IMG_FILE_IS_BLK_DEV"]} -ne 0 ] ; then
                        if [ ${SUMO__VARS["CREATE_FILE"]} -eq 0 ] ; then
                                ${__SUDO__}chown ${USER}:${USER} "${mountpoint}"
                        fi
                fi

                local foundSource=""
                if Dev__findMountSource "${mountpoint}" foundSource ; then
                        SUMO__VARS["DEVPART"]="$foundSource"
                        SUMO__VARS["DEVMAPPER"]=${SUMO__VARS["DEVPART"]}
                        _log "Successfully mounted folder '${mountpoint}' from device ${SUMO__VARS["DEVMAPPER"]} !"

                        if [ ${SUMO__VARS["IMG_FILE_IS_BLK_DEV"]} -ne 0 ] ; then
                                #Sumo__updateSavedRecentList "${SUMO__VARS["DEVPART"]}" "${mountpoint} " "${SUMO__VARS["IMG_DISK_FILE_PATH"]}" "mount"
                                Sumo__updateSavedRecentList "${SUMO__VARS["IMG_DISK_FILE_PATH"]}" "${mountpoint} " "${SUMO__VARS["IMG_DISK_FILE_PATH"]}" "mount"
                        else
                                Sumo__updateSavedRecentList "${SUMO__VARS["DEVPART"]}" "${mountpoint} " "${verafile}" "mount"
                        fi
                else
                        _log_warn "Internal failure. Mounting via veracrypt was successful, but failed to find back the backdoor system device from mount point '${mountpoint}'."
                fi

                Sumo__listCurrentDevice "${SUMO__VARS["DEVPART"]}"
                #veracrypt -l 1>&2

        else
                _log_err "failed to mount ${SUMO__VARS["DEVMAPPER"]} on ${mountpoint}."
        fi

        return ${cryptopen_res}
}



Sumo__vera_unmount()
{
    if ! Sumo__vera_isInstalled ; then
        return 1
    fi

    SUMO__CURRENT_OPERATION="unmount"

    _log_dbg "veracrypt DEVPART='${SUMO__VARS["DEVPART"]}' SUMO__VARS["MOUNT_POINT"]='${SUMO__VARS["MOUNT_POINT"]}'"

:<<'EOF'
    Vera volumes cannot be unmounted using the block device path.    
    Please specify any of the following:                    
    1) Path to the encrypted VeraCrypt volume.
    2) Mount directory of the volume's filesystem (if mounted).
    3) Slot number of the mounted volume (requires --slot).

    Here, vera crypt is eventually always unmounted based on the mount point, which is 
    either retrieved from the file itself (file-based unmount allowed for Vera) 
    or as above from the device mapper
EOF
    local veracmd=""
    local unmountmsg=""
    local res
    if [ ! -z "${SUMO__VARS["FS_LABEL"]}" ] && Int__isInt "${SUMO__VARS["FS_LABEL"]}" ; then
            veracmd="veracrypt -d --slot=${SUMO__VARS["FS_LABEL"]}"
            unmountmsg="label/slot ${SUMO__VARS["FS_LABEL"]}"
    else
            veracmd="veracrypt -d \"${SUMO__VARS["MOUNT_POINT"]}\""
            unmountmsg="folder ${SUMO__VARS["MOUNT_POINT"]} from ${SUMO__VARS["DEVPART"]}"
    fi
    _logf "UNMOUNT COMMAND: $veracmd"
    eval "$veracmd"
    res=$?
    if [ $res -eq 0 ] ; then
            _log "Successfully unmounted $unmountmsg (vera)"

             Sumo__updateSavedRecentList "${SUMO__VARS["DEVPART"]}" "${SUMO__VARS["MOUNT_POINT"]} " "${SUMO__VARS["IMG_DISK_FILE_PATH"]}" "unmount"

            return 0
    else
            _log_err "Failed to unmount VERA volume."
            if [ -z "${SUMO__VARS["SILENT"]}" ] ; then 
                    _log_err "List of currently opened volume is the following (veracrypt -l):"
                    veracrypt -l 1>&2
            fi
            return -1 #Failed to unmount VERA volume!"
    fi    
}

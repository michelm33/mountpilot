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
# Release file path: sumo__overlay.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-10-28 19:08:06.542205936 +0000
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

:<<'EOF'
Indicates whether the input given pertains to an overlay mount operaiton
EOF

Sumo__isOverlay() {       
        if [ ! -z "${SUMO__VARS["LOWER_DIRS"]}" ] ; then
                return 0
        fi

        return 1
}

:<<'EOF'
Retrieves the mount point(s) for a given source.

@param [1] mount source
@output global Sumo__targetsListOfMyselfOwner the array of found targets when multiple targets where found.
@output global SUMO__VARS["MOUNT_POINT"] and SUMO__VARS["MOUNT_POINT"]. 
        In case of multiple targets, the first target of the list is used to initialize "MOUNT_POINT"
@returns 0 if a mount point was found, 1 otherwise
EOF

Sumo__overlay_resolveMountingInfos_NO() {
        _log_dbg "${FUNCNAME[0]} for source '$1'"

        local source="$1"
        local targetDir=""

        # If the preliminary mount resolution based on an input mount point 
        # was already successful, we don't need to continue
        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ] && [ ! -z "${SUMO__VARS["MOUNT_POINT_SOURCE"]}" ] && [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ]  ; then
                return 0
        fi

        if Dev__findMountPoint "${source}" targetDir ; then    
                _log_dbg "${FUNCNAME[0]}: found target '$targetDir'"

                if [ ${SUMO__VARS["CREATE_FILE"]} -eq 0 ] ; then
                        _exit -1 "Disk '${SUMO__VARS["IMG_FILE"]}' can not be created. Some parameters conflicts with already mounted source '$source' (conflicting label '${SUMO__VARS["FS_LABEL"]}'?)."
                fi

                local testTargetDir="$targetDir"
                Str__toTail testTargetDir $'\n' last
                local NbFoundTargetsInThisCall=0
                #echo "TAIL :'$testTargetDir' mp='${SUMO__VARS["MOUNT_POINT"]}'"
                if [ "$testTargetDir" != "$targetDir" ] ; then
                        if [ ${SUMO__VARS["DO_UNMOUNT"]} -ne 0 ]; then
                                _log_warn "'${source}' is already mounted multiple times:"
                        else
                                _log_warn "'${source}' is currently mounted multiple times:"
                        fi
                        while IFS='' read -r targetLine
                        do
                                Str__trim "$targetLine" targetLine                        
                                local targetOwner=""
                                targetOwner="$(timeout -s SIGKILL 1 stat -c "%U" "$targetLine")" # %G")
                                if [ -z "$targetOwner" ] ; then
                                        # when stat fails (connection broken?)
                                        # assume current user
                                        targetOwner="${SUMO__VARS["OWNER"]}" 
                                fi
                                _log_warn "- Folder '$targetLine' owned by '$targetOwner'"

                                if [ "$targetOwner" == "${SUMO__VARS["OWNER"]}" ] ; then
                                        Sumo__targetsListOfMyselfOwner+=("$targetLine")
                                        Sumo__devicesOftargetsListOfMyselfOwner+=("$source")
                                        NbFoundTargetsInThisCall=$(($NbFoundTargetsInThisCall + 1))
                                fi
                        done <<<"$targetDir"

                        targetDir="${Sumo__targetsListOfMyselfOwner[0]}" # If there are existing multiple points it won't prevent us to mount another
                else
                        NbFoundTargetsInThisCall=1
                        Sumo__targetsListOfMyselfOwner+=("$targetDir")
                        Sumo__devicesOftargetsListOfMyselfOwner+=("$source")
                fi

                if [ ${SUMO__VARS["DO_UNMOUNT"]} -ne 0 ]; then # Mounting request
                        if [ -z  "${SUMO__VARS["MOUNT_POINT"]}" ] ; then
                                # Save the mounted mount point only if not already explicitly set by argument
                                SUMO__VARS["MOUNTED"]=0                
                                SUMO__VARS["MOUNT_POINT"]="$targetDir"
                        fi
                        #_quit "${source} mounted on ${SUMO__VARS["MOUNT_POINT"]} is already mounted."
                        if [ $NbFoundTargetsInThisCall -eq 1 ] ; then # do not duplicate warning with above                                
                                _log_warn  "'${source}' already mounted on '${targetDir}'."
                        fi
                else # unmounting request
                        if [ ${#Sumo__targetsListOfMyselfOwner[@]} -ne 1 ] && [ ! -v SUMO__VARS["ALL_FLAG"] ]  ; then
                              _exit -1 "Please unmount by specifying the exact folder name or use option -a to unmount all at once."
                        fi
                        SUMO__VARS["MOUNTED"]=0                
                        SUMO__VARS["MOUNT_POINT"]="$targetDir"
                fi
                return 0                
        fi
        #_log_dbg "${FUNCNAME[0]}: no target found !"

        return 1
}

:<<'EOF'
    @param1 in raw options (full)
    @param2 out upperdir
    @param3 out lower dir(s) array
EOF
Sumo__overlay_findDirsFromMountOptions() {
    local options="$1"
    local -n __out_upperdir=$2
    local -n __out_lowerdirs=$3

    Str__trim "$options" options
    #_log_dbg "has read options line: '$options'"
    local optionList=()
    readarray -t -d',' optionList <<< "$options"
    local option
    local upperRead=false
    local lowerRead=false
    for option in "${optionList[@]}" ; do
        local optionArgs=()
        Str__trim "$option" option
        #_log_dbg "has read option '$option'"
        readarray -t -d'=' optionArgs <<< "$option"

        local optionValue="${optionArgs[1]}"
        Str__trim "$optionValue" optionValue
        #_log_dbg "has read option value '${optionValue}'" 
        
        if Str__startsWith "$option" "upperdir" ;  then
            __out_upperdir="${optionValue}" 
            upperRead=true
            #_log_dbg "FOUND uppper '${__out_upperdir}'"
        elif Str__startsWith "$option" "lowerdir" ;  then
            local __fdf_lowerdirs=()
            local __fdf_lowerdir=""
            readarray -t -d':' __fdf_lowerdirs <<< "${optionValue}"  # Lets handle multi lower dir cases too
            for __fdf_lowerdir in "${__fdf_lowerdirs[@]}" ; do
                Str__trim "$__fdf_lowerdir" __fdf_lowerdir
                __out_lowerdirs+=("$__fdf_lowerdir")
            done
            lowerRead=true
            #_log_dbg "FOUND lower list '${__out_lowerdirs[@]}' ${!__out_lowerdirs}"
        fi

        if $lowerRead && $upperRead ; then
            break
        fi
    done
}

Sumo__overlay_resolveMountingInfos() {
    _log_dbg "Sumo__overlay_resolveMountingInfos for MOUNT_POINT '${SUMO__VARS["MOUNT_POINT"]}'"
    if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] ; then 
        local foundSource="${SUMO__VARS["MOUNT_POINT_SOURCE"]}"

        if [ -z "$foundSource" ] ; then
                # If a mount folder is specified, resolve the device path and its parent.
                if Dev__findMountSource "${SUMO__VARS["MOUNT_POINT"]}" foundSource ; then
                        SUMO__VARS["MOUNTED"]=0
                        Sumo__targetsListOfMyselfOwner+=("${SUMO__VARS["MOUNT_POINT"]}")
                        Sumo__devicesOftargetsListOfMyselfOwner+=("$foundSource")
                fi # else, foundSource is still empty
        fi

        if [ ! -z "$foundSource" ] ; then    
                if [ ${SUMO__VARS["DO_UNMOUNT"]} -ne 0 ]; then
                        _quit "Folder ${SUMO__VARS["MOUNT_POINT"]} is already mounted."
                fi
                Sumo__resolveBlockDeviceMountingInfos "$foundSource" 1 # 1=do not seek mount points
        fi
    else
        if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
            #findmnt -n --pairs -o FSTYPE,TARGET,OPTIONS|sed -E 's/""/"-"/g' | sed -E 's#[A-Z]+="([^"]+)"#\1 |#g' 2>>"${__LOG_ERR_FILE__}"
            local formattedMountInfos="$(findmnt -n --pairs -o FSTYPE,TARGET,OPTIONS|sed -E 's/""/"-"/g' | sed -E 's#[A-Z]+="([^"]+)"#\1 |#g' | \
            awk -i "${SUMO__VARS["SUMO__MY_DIR"]}/awk-api/awk-api-core.awk" -F'|' '{ fstype=trim($1); if (fstype == "overlay") print $0; }'  \
            2>>"${__LOG_ERR_FILE__}")"
            if [ -z "${formattedMountInfos}" ] ; then
                _log_dbg "No overlay mount found at all."
                return 0 # Return 0. SUMO__VARS["MOUNTED"] must checked for unmounts 
            fi
            local line=""
            local mountpoint=""

            local inputUpperDir="$(realpath -m "${SUMO__VARS["IMG_FILE"]}")"
            local inputLowerDirsAbsPath=""
            local inputLowerdirs=()
            local inputLowerdir=""
            readarray -t -d':' inputLowerdirs <<< "${SUMO__VARS["LOWER_DIRS"]}"  # Lets handle multi lower dir cases too
            for inputLowerdir in "${inputLowerdirs[@]}" ; do
                Str__trim "$inputLowerdir" inputLowerdir
                inputLowerDirsAbsPath+="${inputLowerDirsAbsPath}:$(realpath -m "$inputLowerdir")"
            done
            Str__trimStart "${inputLowerDirsAbsPath}" inputLowerDirsAbsPath ":"

            while IFS='' read -r line ; do
                _log_dbg "line : '$line'"
                local mntInfoFields=()
                readarray -t -d'|' mntInfoFields <<< "$line"
                local mountpoint="${mntInfoFields[1]}"
                local options="${mntInfoFields[2]}"
                Str__trim "$mountpoint" mountpoint
                local upperdir=""
                local lowerdirs=()
                Sumo__overlay_findDirsFromMountOptions "$options" upperdir lowerdirs

                local allReadLowerDirsFound=true
                local lowerdir
                for lowerdir in "${lowerdirs[@]}" ; do
                    if ! Array__contains_by_string "${inputLowerDirsAbsPath}" "${lowerdir}" ; then
                        allReadLowerDirsFound=false
                        break
                    fi
                done
                _log_dbg "'${inputUpperDir}' $allReadLowerDirsFound ${#lowerdirs[@]} ${SUMO__VARS["NB_LOWER_DIRS"]}"
                if [ "${inputUpperDir}" = "${upperdir}" ] && $allReadLowerDirsFound && [ ${#lowerdirs[@]} -eq ${SUMO__VARS["NB_LOWER_DIRS"]} ] ; then
                    SUMO__VARS["MOUNTED"]=0
                    SUMO__VARS["MOUNT_POINT"]="$mountpoint"
                    Sumo__targetsListOfMyselfOwner+=("${SUMO__VARS["MOUNT_POINT"]}")

                    local logicalMountSource
                    Sumo__overlay_buildLogicalMountSourceFromRealPath upperdir lowerdirs logicalMountSource
                    _log_dbg "=>>>>>>>>>>>>>>>'${logicalMountSource}'"
                    Sumo__devicesOftargetsListOfMyselfOwner+=("$logicalMountSource")
                    break
                fi
            done <<<"${formattedMountInfos}"
        fi
    fi
}

Sumo__overlay_buildLogicalMountSourceFromMountOptions()
{    
    local __upperdir=""
    local __lowerdirs=()
    local __in_mountOpt="$1"
    local -n __out_src=$2
    local __realpath=$3
    if Str__contains "$mountOpt" "upperdir=" ; then
        Sumo__overlay_findDirsFromMountOptions "${__in_mountOpt}" __upperdir __lowerdirs
        if ${__realpath} ; then
            Sumo__overlay_buildLogicalMountSourceFromRealPath __upperdir __lowerdirs __out_src
        else
            Sumo__overlay_buildLogicalMountSource __upperdir __lowerdirs __out_src
        fi
    fi
}

Sumo__overlay_buildLogicalMountSourceFromRealPath()
{
    local -n __in_upperdir=$1
    local -n __in_lowerdirs=$2
    local -n __out_logicalMountSource=$3
echo $__out_logicalMountSource
    __out_logicalMountSource="${__in_upperdir}"
    local __lowerdir
    for __lowerdir in "${__in_lowerdirs[@]}" ; do 
        __out_logicalMountSource="${__out_logicalMountSource}>${__lowerdir}"
    done

}

Sumo__overlay_buildLogicalMountSource()
{
    local -n __in_upperdir=$1
    local -n __in_lowerdirs=$2
    local -n __out_logicalMountSource=$3

    File__basename "$__in_upperdir" __out_logicalMountSource
    local __lowerdir
    for __lowerdir in "${__in_lowerdirs[@]}" ; do 
        local __lowerdirBasename
        File__basename "$__lowerdir" __lowerdirBasename
        __out_logicalMountSource="${__out_logicalMountSource}>${__lowerdirBasename}"
    done
}

Sumo__overlay()
{
    if ! Sumo__isOverlay ; then return 1 ; fi

    if ! Sumo__overlay_resolveMountingInfos ; then
        _exit -2 "Failed to resolve mounting infos (Sumo__overlay_resolveMountingInfos failed). Please check the logs."
    fi

    if [ ${SUMO__VARS["DO_UNMOUNT"]} -eq 0 ]; then
        #_log "unmount overlay command"

        if [ ${SUMO__VARS["MOUNTED"]} -eq 0 ] ; then
            #_log_dbg "unmount OK MOUNTED IS SET"
            Sumo__unmount  # This should be the last step
            _exit -1 "Internal error - Script did not exit after unmount."
        else
            _exit -2 "Overlay is not mounted."
            #_log_err "Internal error: unmount but MOUNTED NOT SET"
            #Sumo__overlay_resolveMountingInfos            
        fi
    else
        if [ ${SUMO__VARS["MOUNTED"]} -ne 0 ] ; then
            #_log "mount overlay command"
            Sumo__overlay_determineMountPoint
            Sumo__overlay_mount
            _exit $? ""
        else
            _exit -2 "${SUMO__VARS["DEVPART"]} is already mounted."
        fi
    fi

}


:<<'EOF'
Function used to determine or let user enter the mountpoint
EOF

Sumo__overlay_determineMountPoint()
{
    # The check here below are done for the cases of a mounting or a creation (not unmounting)
    if [ ! -z "${SUMO__VARS["MOUNT_POINT"]}" ] ; then
            Sumo__manageValidMountpointSetting Sumo__getMountpoint "${SUMO__VARS["MOUNT_POINT"]}"                        
    else
            Sumo__manageValidMountpointSetting Sumo__getMountpoint 
    fi
}

:<<'EOF'
Overlay mount function
EOF

Sumo__overlay_mount()
{
        SUMO__CURRENT_OPERATION="mount"

        cmd="Sumo__cloud_mount_${SUMO__VARS["DEVPART"]}"

        local fullPathMountSourceForRecentListEntry=""
        local mountpoint="$(realpath -m "${SUMO__VARS["MOUNT_POINT"]}")"
        local upperdirParent
        local upperdir="$(realpath -m "${SUMO__VARS["IMG_FILE"]}")"
        File__dirname "${upperdir}" upperdirParent
        fullPathMountSourceForRecentListEntry="${upperdir}"
        local lowerDirsAbsPath=""
        local lowerdirs=()
        local lowerdir=""
        readarray -t -d':' lowerdirs <<< "${SUMO__VARS["LOWER_DIRS"]}"  # Lets handle multi lower dir cases too
        for lowerdir in "${lowerdirs[@]}" ; do
            Str__trim "$lowerdir" lowerdir
            local lowerDirAbsPath=$(realpath -m "$lowerdir")
            lowerDirsAbsPath+="${lowerDirsAbsPath}:${lowerDirAbsPath}"
            fullPathMountSourceForRecentListEntry="${fullPathMountSourceForRecentListEntry}>${lowerDirAbsPath}"
        done
        Str__trimStart "${lowerDirsAbsPath}" lowerDirsAbsPath ":"


        cmd="${__SUDO__}mount -t overlay -o lowerdir='${lowerDirsAbsPath}',upperdir='${upperdir}',workdir='${upperdirParent}/.workdir' none '${mountpoint}'"
        _logf "MOUNT COMMAND: $cmd"
        local ret
        eval "$cmd" 
        ret=$?
        if [ $ret -eq 0 ] ; then
            _log "Successfully mounted upper directory '${upperdir}' over lower directory(ies) '${lowerDirsAbsPath}' on '${mountpoint}'."

:<<'EOF'
            local lowerdirs=(${SUMO__VARS["LOWER_DIRS"]}) # TODO may not work with spaces inside
            local logicalMountSource="${SUMO__VARS["IMG_FILE"]}"
            logicalMountSource="${logicalMountSource}>${lowerdirs//:/<}"
EOF
            _log_dbg "Sumo__overlay_mount:  Sumo__updateSavedRecentList for '${logicalMountSource}': key $fullPathMountSourceForRecentListEntry"

            Sumo__updateSavedRecentList "${fullPathMountSourceForRecentListEntry}" "${SUMO__VARS["MOUNT_POINT"]}" "" "mount" "${fullPathMountSourceForRecentListEntry}"
            #Sumo__updateSavedRecentList "${logicalMountSource}" "${SUMO__VARS["MOUNT_POINT"]}" "" "mount" "${fullPathMountSourceForRecentListEntry}"
        else
            _log_err "Failed to mount upper directory '${upperdir}' over lower directory(ies) '${lowerDirsAbsPath}' on '${mountpoint}'. Please check log files for more details."
        fi
        return $ret
}

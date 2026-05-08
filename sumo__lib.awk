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
# Release file path: sumo__lib.awk
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-08-04 20:35:18.214599567 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# A library of SUMO-specific functions reused from several other awk sources.
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

# Walks down a only child lineage to find the last descendant.
# This is used to find delegate devices to unmount root devices
function findOnlyChildLastDescendant(inDevice)
{
    #log_dbg("findOnlyChildLastDescendant for " inDevice " nb childs " nbChilds[inDevice])
    lastDescendant=""
    while (nbChilds[inDevice]==1)
    {
        inDevice=childMap[inDevice]        
        lastDescendant=inDevice
        #log_dbg("[in] findOnlyChildLastDescendant for " inDevice " nb childs " nbChilds[inDevice])
    }

    if ((length(lastDescendant) > 0) && (nbChilds[inDevice] > 1))
    {
        # Only keep only childs
        lastDescendant=""
    }
    return lastDescendant
}

function getAncestor(devpath,recurse)
{
        ancestor=ancestorMap[devpath]
        if (recurse)
        {
                while (length(ancestorMap[ancestor]) > 0) 
                {
                        ancestor = ancestorMap[ancestor]    
                }
        }
        if (length(ancestor) == 0) 
                return ""
        else
                return ancestor
}

function getVisibleAncestor(devpath,recurse)
{
    ancestor=""
    if (length(excludeDevices[devpath])==0) # not excluded
    {
        ancestor=ancestorMap[devpath]
        if (recurse)
        {
                while ((length(ancestorMap[ancestor]) > 0) && (length(excludeDevices[ancestorMap[ancestor]])==0) )
                {
                ancestor = ancestorMap[ancestor]    
                }
        }
    }
    if ((length(ancestor) == 0) || (length(excludeDevices[ancestor])>0) )
        return ""
    else
        return ancestor
}


function getFilePathFromDevPath(devpath) {
    # Find the root ancestor
    ancestor=devpath

    #print "file path for devpath",devpath  | "cat 1>&2"  
    firstNotExcludedAncestor=devpath
    while (length(ancestorMap[ancestor]) > 0)
    {
        ancestor = ancestorMap[ancestor]  
        if (!isExcluded(ancestor))
        {
            if ( (firstNotExcludedAncestor==devpath) || doGetFilenamesForAllDevices)
                firstNotExcludedAncestor=ancestor
        }

        #print "devpath new ancestor found",ancestor    | "cat 1>&2"
    }

    #log_dbg("getFilePathFromDevPath: " devpath " final ancestor found " ancestor ", first not excluded :" firstNotExcludedAncestor)
    #if ((firstNotExcludedAncestor != devpath) && !doGetFilenamesForAllDevices)
    #{
    #    _deviceFile="" 
    #}
    #else 
    if (startsWith(ancestor,"/dev/loop"))
    {
        #_deviceFile=exec("/sbin/losetup --list -n -O NAME,BACK-FILE|awk -F' ' -v DEV="ancestor" '{ if ((NF==2) && ($1==DEV)) print $2 }' | sort -r 2>/dev/null")
        _deviceFile=loopBackFile[ancestor] # optimized version
    }
    else if (startsWith(ancestor,"/dev/nbd"))
    {
        _deviceFile=nbdBackFile[ancestor]
    }
    else
    {
        _deviceFile="" # Don't forget to reset , as it is global
    }

    #if (length(_deviceFile) > 0)
    #    log_dbg("****** getFilePathFromDevPath: FOR DEVICE " devpath " FILE FOUND: " _deviceFile)

    #    if ((length(HOME)>0) && ((length(HOME_REPLACE)>0)))
    #        gsub(HOME,HOME_REPLACE, _deviceFile)

    mapDevPathFilePath[devpath]=trim(_deviceFile)
    #debug=sprintf("'%s'", mapDevPathFilePath[devpath]);

    # For all device we keep track of the related file
    # However, only the name for the actual visible root device is returned by this function
    if ((firstNotExcludedAncestor != devpath) && !doGetFilenamesForAllDevices)
        return ""
    else
        return mapDevPathFilePath[devpath]
}

function addChild(devParent,devChild)
{
    if (length(nbChilds[devParent])==0)
    {
        nbChilds[devParent]=0
        childMap[devParent]=devChild
        nbChilds[devParent]=nbChilds[devParent]+1
    }
    else
    {
        if (childMap[devParent] == devChild)
        {
            // Do not count already registered childs
            #log_warn("child device " devChild " already registered for parent " devParent)
        }
        else
        {
            childMap[devParent]=devChild
            nbChilds[devParent]=nbChilds[devParent]+1
        }
    }
}

function setupAncestor()
{
        # Build the ancestor map. 
        nbLinesAncestry=split(ancestry,ancestorEntries,"\n")
        for (i=1; i <=nbLinesAncestry; i++ )
        {
            nbFields=split(ancestorEntries[i],entryFields," ")
            mntp=entryFields[1]
            gsub(/^["]/, "", mntp);
            gsub(/["]$/, "", mntp);
            gsub("§"," ", mntp);
            if (mntp=="-") mntp=""
            #print ancestorEntries[i]," mountpoint:"mntp|"cat 1>&2"
            devSource=""
            f_0=""
            if (nbFields > 0)
            {
                devSource=entryFields[nbFields]
                f_0=escapeSpaces(devSource,spaceShadownChar)                
                if (length(mountpointMap[f_0]) > 0)
                {
                        f_0=f_0"§§DUPLICATE_"i
                }
            }

            if (nbFields == 3)
            {
                mountpointMap[f_0]=mntp
            }
            else if (nbFields > 3)
            {
                f_1=escapeSpaces(entryFields[nbFields-1],spaceShadownChar)
                if (mntp!="") hasMountedChilds[f_1]=1
                if (nbFields > 4)
                {
                        f_2=escapeSpaces(entryFields[nbFields-2],spaceShadownChar)
                        if (mntp!="") hasMountedChilds[f_2]=1
                        ancestorMap[f_1]=f_2
                        #mountpointMap[f_1]=mntp
                        addChild(f_2,f_1)
                        #                print f_2,"is the f_2 ancestor of", f_1 | "cat 1>&2"

                        if (nbFields > 5)
                        {
                                f_3=escapeSpaces(entryFields[nbFields-3],spaceShadownChar)
                                if (mntp!="") hasMountedChilds[f_3]=1

                                ancestorMap[f_2]=f_3
                                #mountpointMap[f_2]=mntp
                                addChild(f_3,f_2)
                                #                print f_3,"is the f_3 ancestor of", f_2| "cat 1>&2"
                        }
                }
                ancestorMap[f_0]=f_1
                mountpointMap[f_0]=mntp
                addChild(f_1,f_0)
                #                print f_1,"is the f_1 ancestor of", f_0| "cat 1>&2"
            }
        }

       # Get first the file names from the basic ancestry tree

        for (i=1; i <=nbLinesAncestry; i++ )
        {
            #log_dbg("in loop to get file names: " ancestorEntries[i])
            nbFields=split(ancestorEntries[i],entryFields," ")
            if (nbFields >= 3)
            {
                aChildDevice=entryFields[nbFields]
                #log_dbg("child device:" aChildDevice)
                {
                        if (length(fileToDevMap[aChildDevice]) == 0)
                        {
                                file=getFilePathFromDevPath(aChildDevice)
                                fileToDevMap[aChildDevice]=file
                        }
                        file=fileToDevMap[aChildDevice]
                        # log_dbg("file for child device:" aChildDevice " " file)
                }
            }
        }

        # Complete the ancestor map with hidden hierachy for lsblk, like a mounted disk file on another mounted partition

        for (i=1; i <=nbLinesAncestry; i++ )
        {
            # print ancestorEntries[i]|"cat 1>&2"
            nbFields=split(ancestorEntries[i],entryFields," ")
            if (nbFields >= 3)
            {

                aChildDevice=entryFields[nbFields]
                # print "child device:",aChildDevice|"cat 1>&2"
                {
                        if (length(fileToDevMap[aChildDevice]) == 0)
                        {
                                file=getFilePathFromDevPath(aChildDevice)
                                fileToDevMap[aChildDevice]=file
                        }
                        file=fileToDevMap[aChildDevice]
                        if (length(file)>0) 
                        {
                                # print "\n\nhandling file",file," found for device",aChildDevice|"cat 1>&2"
                                for (key in mountpointMap) 
                                { 
                                        mountPoint=trim(mountpointMap[key])
                                        if ((length(mountPoint) > 1) && (length(file)>length(mountPoint))) # to exclude "/"
                                                {
                                                leadingPath=substr(file,1, length(mountPoint))
                                                firstCharAfterLeadingPath=substr(file,length(mountPoint)+1, 1)
                                                # print "key match",key,mountPoint,"leadingpath",leadingPath,"first char",firstCharAfterLeadingPath|"cat 1>&2"
                                                if ((firstCharAfterLeadingPath=="/") && (leadingPath == mountPoint))
                                                {
                                                        f_0=escapeSpaces(aChildDevice,spaceShadownChar)
                                                        # printf("old ancestor '%s'\n", ancestorMap[f_0])|"cat 1>&2"
                                                        ancestorMap[f_0]=key
                                                                mntp=entryFields[1]
                                                                gsub(/^["]/, "", mntp);
                                                                gsub(/["]$/, "", mntp);
                                                                if (mntp=="-") mntp=""
                                                                mountpointMap[f_0]=mntp
                                                                addChild(key,f_0) # if multiple?
                                                        hasMountedChilds[key]=1
                                                        # print "ancestor for ",f_0,"is ",key,"Found",mountpointMap[key],key," as parent of ",file,"aChildDevice:",aChildDevice|"cat 1>&2"
                                                }
                                        }
                                }
                        }       
                }   
                #               print i,"/",nbLinesAncestry|"cat 1>&2"
            }
        }
}

function acceptDevice(candidateDevicePath,deviceFilters, negativeFiltersOnly) 
{
        #log_dbg("acceptDevice: testing " candidateDevicePath " with filters:" deviceFilters "negativeonly: " negativeFiltersOnly)
        # Always accepted when no filter defined

        if (length(deviceFilters)==0) return 1 # true

        candidateDeviceType=""

        if (startsWith(candidateDevicePath,"/dev/loop"))
                candidateDeviceType="loop"
        else                
        if (startsWith(candidateDevicePath,"/dev/nbd"))
                candidateDeviceType="nbd"

        for(i=1; i<=nbDeviceFilters; i++)
        {
                filter=deviceFilters[i]
                #log_dbg("filter:" filter)
                if (match(filter,"^no")!=0) # explicit exclusion
                {
                        split(filter,negFilter,"no");                           
                        if (candidateDeviceType == negFilter[2]) return 0; # We found one to exclude. # Finally test if it matches device type
                }
                else 
                {
                        if (candidateDeviceType == filter) return 1; # This one we found, return true                                
                }
                # else continue
        }
        # By default, if there were filters defined and we fall through this function
        # it means the device should not be accepted
        # if there were only neg filters defined, by default accept if not refused before 
        # while handling the no- filter. Otherwise, it should be accepted only if explicitly 
        # selected by the filter
        return negativeFiltersOnly 
}

function exclude(devpath)
{
        # print "exclude",devpath|"cat 1>&2"
        excludeDevices[devpath]=1
}

function isExcluded(devpath)
{
        # Return true if explicitly or already excluded
        #  according to the device filter(s)
        if (excludeDevices[devpath]==1)
        {
                return 1
        }

        # Intermediate veracrypt device mappers are implicitely excluded
        if (startsWith(devpath,MAPPERDIR "/veracrypt"))
        {
                if (length(mapVeraDeviceMappers[devpath]) == 0) # It is not a final VERA mapper
                {
                        _veraAncestor=getAncestor(devpath,1)
                        #log_dbg("_veraAncestor for " devpath " is " _veraAncestor)
                        #log_dbg("_veraAncestor " _veraAncestor " is excluded? " isExcluded(_veraAncestor))
                        # Exclude only if the root ancestor is also excluded.
                        # For VERA disk file, the root is a loop device
                        if (isExcluded(_veraAncestor))
                        {
                            exclude(devpath)
                            return 1
                        }
                        else
                        {
                            return 0
                        }
                }
        }
        return 0
}

function getLoopBackFiles()
{
    # Get the list of loops to avoid having to execute complex subprocess from getFilePathFromDevPath 
    losetup_list_cmd="/sbin/losetup --list -n -O NAME,BACK-FILE"
    while ( (losetup_list_cmd | getline loop_item) > 0)
    {
        nbLoopItemFields=split(loop_item, loopItemFields, " ")
        if (nbLoopItemFields==2)
        {
           # Perform a first exclusion of basic block devices of type 'loop'
           loopBackFile[loopItemFields[1]]=loopItemFields[2]
           # log_dbg(loopItemFields[1] " " loopBackFile[loopItemFields[1]])
            if (! acceptDevice(loopItemFields[1], deviceFilters, negativeFiltersOnly))
            {
                exclude(loopItemFields[1])
            }
        }
    }
}

function getNBDBackFiles()
{
    # Get the list of nbd devices to avoid having to execute complex subprocess from getFilePathFromDevPath 
    # ex. of ps output: qemu-nbd -c /dev/nbd0 /home/mike/test/imgdisk.qcow2 -f qcow2
    nbd_list_cmd="ps -C qemu-nbd -o cmd="
    while ( (nbd_list_cmd | getline nbd_item) > 0)
    {
        nbNbdItemFields=split(nbd_item, nbdItemFields, " ")
        if (nbNbdItemFields>=4)
        {
           # Perform a first exclusion of basic top block devices of type 'nbd'
           nbdBackFile[nbdItemFields[3]]=nbdItemFields[4]

        #debug:
        #log_warn(nbdItemFields[3] " " nbdBackFile[nbdItemFields[3]] " device filters:")

        #for (devFilter in deviceFilters) log_warn(deviceFilters[devFilter])
            #if (! acceptDevice(nbdItemFields[3], deviceFilters, negativeFiltersOnly))
            #{
            #    exclude(nbdItemFields[3])
            #}
        }
    }
}

function getVERABackFiles()  # initializes global array 'mapVeraDeviceMappers'
{
    allVeraDeviceMappers=Vera__getAllDeviceMapper()
    nbVeraDeviceMappers=split(allVeraDeviceMappers, veraDeviceMappers, "\n")
    for (veraDeviceMapper in veraDeviceMappers)
    {
        #log_dbg("VERA MAPPER: " veraDeviceMappers[veraDeviceMapper])
        mapVeraDeviceMappers[veraDeviceMappers[veraDeviceMapper]]=veraDeviceMappers[veraDeviceMapper]
    }
}

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
# Release file path: sumo__list.awk
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-04 20:52:31.863315297 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# Implements the SUMO list function. The produced output list has a specific format
# which is processed by the parent only for display purposes.
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

function isNegativeOnlyFilter(deviceFilters) 
{
        nbDeviceFilters=length(deviceFilters)
        if (nbDeviceFilters==0) return 0
        for(i=1; i<=nbDeviceFilters; i++)
        {
                if (match(deviceFilters[i],"^no")!=0) ; # continue
                else if (tolower(deviceFilters[i])=="free") ; # continue
                else if (tolower(deviceFilters[i])=="all") ; # continue
                else { return 0; }
        }
        return 1 # if we arrived till here, there were only neg filters
}

function isValidSoftDeviceType(softDevTypeName)
{
        return length(allsoftdevtypesTable[softDevTypeName]) > 0
#        for (fs=1; fs <= length(allsoftdevtypesTable); fs++)
#        {
#                # log_dbg("checking fs '" fsname "' with '" fstypesTable[fs] "'")
#                if (allsoftdevtypesTable[fs] == softDevTypeName) return 1; # We found one fs to exclude.
#        }
#        return 0
}


function isValidFilesystem(fsname)
{
        return length(fstypesTable[fsname]) > 0
#        for (fs=1; fs <= length(fstypesTable); fs++)
#        {
#                # log_dbg("checking fs '" fsname "' with '" fstypesTable[fs] "'")
#                if (fstypesTable[fs] == fsname) return 1; # We found one fs to exclude.
#        }
#        return 0
}

function acceptDeviceType(tested_original_src, devtype,deviceFilters, negativeFiltersOnly) 
{
        #log_err("acceptDeviceType: "  tested_original_src ", devIsNet:" devIsNet "devIsAdb:" devIsAdb " testing devtype:" devtype ", fstype:" fstype ", negativeonly: " negativeFiltersOnly)
        # Always accepted when no filter defined

        # The following test may still to be clarified when inside docker
        #if ((devtype == "disk") && (! fileexist(tested_original_src))) return 0;

        if (length(deviceFilters)==0) return 1 # true

        if (devIsNet) 
                ; # OK
        else if (devIsAdb)
                ; # OK
        else if (fstype=="overlay") 
                ; # OK
        else if ((! isValidFilesystem(fstype)) &&  ((devtype=="") || (devtype=="-"))) 
                return 0;
                #if ((devtype=="") || (devtype=="-")) return 0 # invalid device type

        # Otherwise go through the list
        for(i=1; i<=nbDeviceFilters; i++)
        {
                filter=deviceFilters[i]
                #log_dbg("filter:" filter)
                if (match(filter,"^no")!=0) # explicit exclusion
                {
                        split(filter,negFilter,"no");                           
                        if ((negFilter[2]=="docker") && 
                            (fstype=="overlay") && 
                            isDockerOverlayMount(mountoptValues["lowerdir"], mountoptValues["upperdir"], original_mntp))
                        {
                                return 0; # We found a docker overlay mount to excluded
                        }
                        if (isValidFilesystem(negFilter[2]))  return fstype != negFilter[2]; # first check if keyword corresponds to a file system                        
                        if (devtype == negFilter[2]) return 0; # We found one to exclude. # Finally test if it matches device type
                }
                else 
                {
                        #log_warn("fstype: " fstype)

                        if ((filter=="docker") && 
                            (fstype=="overlay") && 
                            isDockerOverlayMount(mountoptValues["lowerdir"], mountoptValues["upperdir"], original_mntp))
                        {
                                return 1
                        }

                        if (isValidFilesystem(filter)) return fstype == filter # first check if keyword corresponds to a file system                        
                        #log_warn("2 fstype: " fstype)
                        #if (devtype == filter) return 1; # This one we found, return true                                
                        #log_warn("devtype: " devtype ", " "filter: " filter)
                        if (index(devtype,filter)) return 1; 
                        if (index(fstype,filter)) return 1; 
                        if (index(tested_original_src,filter)) return 1; 
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


function bypass(devpath,src,mntp)
{
        # print "exclude",devpath,fstype,original_devicetype |"cat 1>&2"

        exclude(devpath)
        ignoredMountedDevices[src]=mntp
        #if (original_devicetype=="loop")
        next
}

function registerProcessedDevice(devpath,mntp)
{
        if (length(nbProcessedDevices)==0)
                nbProcessedDevices=1
#        print "REGISTER",devpath|"cat 1>&2"

        processedDevices[nbProcessedDevices]=devpath
        processedDevicesMountpoints[nbProcessedDevices]=mntp

        nbProcessedDevices = nbProcessedDevices + 1
}

function getNbAncestors(devpath)
{
        nbAncestors=0
        ancestor=ancestorMap[devpath]
        if (length(ancestor) > 0)
        {
                nbAncestors=nbAncestors+1
                while (length(ancestorMap[ancestor]) > 0) 
                {
                        nbAncestors=nbAncestors+1
                        ancestor = ancestorMap[ancestor]    
                }
        }
        return nbAncestors
}

function getNbVisibleAncestors(devpath)
{
    nbAncestors=0
    if (length(excludeDevices[devpath])==0) # not excluded
    {
        ancestor=ancestorMap[devpath]
        if ((length(ancestor) > 0) && (length(excludeDevices[ancestor])==0))
        {
                nbAncestors=nbAncestors+1
                while ((length(ancestorMap[ancestor]) > 0) && (length(excludeDevices[ancestorMap[ancestor]])==0) )
                {
                        nbAncestors=nbAncestors+1
                        ancestor = ancestorMap[ancestor]    
                }
        }
    }
    return nbAncestors
}

function findEmbbedingDisk(devpath)
{
        ancestor=ancestorMap[devpath]
        while ((length(ancestor) > 0) && (length(excludeDevices[ancestor])==0))
        {
                embeddingFile=fileToDevMap[ancestor]
                if (length(embeddingFile) > 0)
                        return embeddingFile
                else
                        ancestor = ancestorMap[ancestor]    
        }
        return ""
}

function getLineColor(devpath)
{
    ancestor=getVisibleAncestor(devpath,1)

    if ((length(ancestor)>0) && (devpath != ancestor))
    {
#print "found color of parent", ancestor,"for",devpath|"cat 1>&2"
        if (length(diskColors[ancestor]) > 0) # the color must have been set
        {
            if (DISPLAY_FORMAT=="bolddisk") 
                return "\033[0m"
            else
                return diskColors[ancestor];
        }
    }
#print "setting color for",devpath,"having parent",ancestor|"cat 1>&2"
    Term__listLinesColorCounter=(Term__listLinesColorCounter + 1)%10
    colorRankValue=Term__listLinesColorCounter
    #local colorRankValue=${Term__Palette[$(( ${Term__listLinesColorCounter} -1 ))]}
    if (DISPLAY_FORMAT=="bgcolor")
        diskColors[devpath]="\033[0;"(40+colorRankValue)"m" 
    else if (DISPLAY_FORMAT=="color") 
        diskColors[devpath]="\033[0;"(30+colorRankValue)"m" 
    else if (DISPLAY_FORMAT=="bolddisk") 
        diskColors[devpath]="\033[1m" 
    else 
        diskColors[devpath]=""

    return diskColors[devpath]
}

function rebuildLineHierarchy(i, parentDevPath, hierarchyLevel) {
        for (i=0;i < nbOutputData;i++)
        {
                devpath=outputDev[i]
  #print ""|"cat 1>&2"
  #indent=""
  #for (k=0;k < hierarchyLevel;k++) indent=indent "-";
  #print indent,i, "rebuild for device:", devpath, ", parent:",parentDevPath, ", visible anc:", getVisibleAncestor(devpath,0), ", cur level:", hiearchyLevel[devpath], ", target level:", hierarchyLevel|"cat 1>&2"
                # Device not yet process on this level?
                if ((length(devpath)>0) && (hiearchyLevel[devpath] == hierarchyLevel)) 
                {
                        if ((length(parentDevPath)==0) || (getVisibleAncestor(devpath,0)==parentDevPath))
                        {
                                # Save the next root at the specified hierarchy
                                newOutputDev[nextIndex]=outputDev[i]
                                if (length(newOutputDevIndex[outputDev[i]])>0) # If multiple mounts on same device
                                        newOutputDevIndex[outputDev[i]]=newOutputDevIndex[outputDev[i]] " " i
                                else
                                        newOutputDevIndex[outputDev[i]]=i

                                nextIndex=nextIndex+1
                                outputDev[i]=""
                                # print "FOUND!"|"cat 1>&2"  
                                rebuildLineHierarchy(0,devpath, hierarchyLevel + 1)
                        }
                }
        }
}

function updateMaxColWidths(rank,string)
{
        sLen=length(string)
        if (sLen > maxColWidths[rank]) { maxColWidths[rank]=sLen }
}

function registerNetworkDevices()
{

        # Add the network devices

        for (i=0; i < length(mountListItems); i++)
        {
                mountedItem=mountListItems[i]
                nbMountingItemInfos=split(mountedItem,mountedItemInfos," ")
                mountedDevpath=mountedItemInfos[1]
                mountedFolder=mountedItemInfos[3]
        #print "network!!",mountedDevpath, mountedFolder|"cat 1>&2"
        #printf("mounted item: '%s'\n",mountedItem)|"cat 1>&2"

                if (nbMountingItemInfos>=4)
                {
                        j=4
                        # This is to handle the case where he mount folder path contains spaces
                        # to concatenate the remaining path parts which were separated by the spaces.
                        # Indeed, in that case, splitting with ' ' is not enough and correct.
                        while (mountedItemInfos[j]!="type")
                        {
                                mountedFolder=mountedFolder" "mountedItemInfos[j]
                                j=j+1 
                        }

                        if (Net__isUNC(mountedDevpath) || Net__isLogin(mountedDevpath))
                        {
        #print "IS UNC!!",mountedDevpath, mountedFolder|"cat 1>&2"
                                if (length(mountedNetDevicesMap[mountedDevpath]) > 0 )
                                {
                                        dupMountedDevpath=mountedDevpath"§§DUPLICATE_"i
                                        mountedNetDevicesMap[dupMountedDevpath]=mountedFolder    
                                        mountedNetDevicesOptionsMap[dupMountedDevpath]=mountedItemInfos[j+2]                                   

                                        registerProcessedDevice(dupMountedDevpath,mountedFolder) 
        #print "register DUP !!",dupMountedDevpath, mountedFolder|"cat 1>&2"
                                }
                                else
                                {
                                        #uniqMountedDevpath=mountedDevpath"_"i
                                        mountedNetDevicesMap[mountedDevpath]=mountedFolder      
                                        mountedNetDevicesOptionsMap[mountedDevpath]=mountedItemInfos[j+2]                                   
        #print "register !!",mountedDevpath, mountedFolder|"cat 1>&2"

                                        registerProcessedDevice(mountedDevpath,mountedFolder) 
                                }
                        }
                }
        }

}

function addOutputData(devpath, file, extraFormat, label, storage, size, avail, fstype, boottype, src, mnt_status, mntp, hiddenDataCol)
{
        if (length(nbOutputData)==0) nbOutputData=0;

        output_data_label[nbOutputData]=label
        output_data_storage[nbOutputData]=storage
        output_data_size[nbOutputData]=size
        output_data_avail[nbOutputData]=avail
        output_data_fstype[nbOutputData]=fstype
        output_data_boottype[nbOutputData]=boottype
        output_data_src[nbOutputData]=src
        output_data_mntstatus[nbOutputData]=mnt_status
        output_data_mntp[nbOutputData]=mntp
        output_data_hidden[nbOutputData]=hiddenDataCol
        output_data_extraFormat[nbOutputData]=extraFormat
        output_data_file[nbOutputData]=file
        outputDev[nbOutputData]=devpath

        #log_dbg("addOutputData at " nbOutputData " :" src mntp )
        nbOutputData=nbOutputData+1
}

function addOutputLineFromIndex(outputDataIndex)
{
        #print "addOutputLineFromIndex " outputDataIndex |"cat 1>&2"

        # This case can happen on multiple mounts of the same device
        if (length(outputFinalForOutputDataIndexDone[outputDataIndex])>0) 
                return 1

        if (length(nbOutputFinal)==0) nbOutputFinal=0;

        label=output_data_label[outputDataIndex]
        storage=output_data_storage[outputDataIndex]
        size=output_data_size[outputDataIndex]
        avail=output_data_avail[outputDataIndex]
        fstype=output_data_fstype[outputDataIndex]
        boottype=output_data_boottype[outputDataIndex]
        src=output_data_src[outputDataIndex]
        mnt_status=output_data_mntstatus[outputDataIndex]
        mntp=output_data_mntp[outputDataIndex]
        hiddenDataCol=output_data_hidden[outputDataIndex]
        extraFormat=output_data_extraFormat[outputDataIndex]


        updateMaxColWidths(0, label)
        updateMaxColWidths(1, storage)
        updateMaxColWidths(2, size)
        updateMaxColWidths(3, avail)
        updateMaxColWidths(4, fstype)
        updateMaxColWidths(5, boottype)
        updateMaxColWidths(6, src)
        updateMaxColWidths(7, "12")
        updateMaxColWidths(8, mntp)

        nbCols=9
        line=label" "storage" "size" "avail" "fstype" "boottype" "src" "mnt_status" "mntp
        lineLength=length(line)
        line=line " " hiddenDataCol
        lineHeaderInfo="[" lineLength "," nbCols "," length(label) "," length(storage) "," length(size) "," length(avail) "," length(fstype) "," length(boottype) "," length(src) "," length("12") "," length(mntp) "]"

        outputFinal[nbOutputFinal]=lineHeaderInfo getLineColor(devpath)""extraFormat"§§"line
        outputFinalForOutputDataIndexDone[outputDataIndex]="yes"

        #log_dbg("outputFinal " outputFinal[nbOutputFinal])
        nbOutputFinal=nbOutputFinal+1
}

function toRelativePathToHome(mntp)
{
    if (startsWith(mntp,HOME))
    {
        #log_err("realpath -m --relative-to \"" currentWorkingDirectory "\" " mntp)        
        newmntp=exec("realpath -s -m --relative-to \"" currentWorkingDirectory "\" " mntp)
        return "./"newmntp
    }
    else
    {
        return mntp
    }
}

function addHierarchyIndent(devpath,src)
{
        # Manage indent for child devices
        itsVisibleAncestor=getVisibleAncestor(devpath,0)
        # print "addHierarchyIndent: '",file,"'",devpath, "nb Ancestors", getNbVisibleAncestors(devpath), "ancestor:",getVisibleAncestor(devpath,0)|"cat 1>&2"
        if (length(itsVisibleAncestor)>0)
        {
                nbAncestors=getNbVisibleAncestors(devpath)
                #single_src_indent="|_§"
                #single_src_indent="\\U023BF§"
                single_src_indent=sprintf("%c§", 187)
                single_src_indent_space="§§"
                src_indent=""
                for (iterForAddHierarchyIndent=1; iterForAddHierarchyIndent <= nbAncestors;iterForAddHierarchyIndent++) {
                        if (iterForAddHierarchyIndent == nbAncestors) 
                                actual_single_src_indent=single_src_indent ; 
                        else 
                                actual_single_src_indent=single_src_indent_space;
                        src_indent=src_indent actual_single_src_indent
                }
                src=src_indent""src
        }
        return src
}

BEGIN {
    split("",Sumo__PartitionTypes," ")

    # Initialize the filters
    nbDeviceFilters=split(comaSeparatedFilters,deviceFilters,",");
    negativeFiltersOnly=isNegativeOnlyFilter(deviceFilters)

    doGetFilenamesForAllDevices=0
    getLoopBackFiles()  # initializes global array 'loopBackFile'
    getNBDBackFiles()   # initializes global array 'nbdBackFile'
    getVERABackFiles()  # initializes global array 'mapVeraDeviceMappers'

    NMCLI_AVAIL=-1
    if (OLDLSBLK=="n")
    {
        MNTLIST_MOUNTPOINT_INDEX=9
        MNTLIST_OPTIONS_INDEX=8
    }
    else
    {
        MNTLIST_MOUNTPOINT_INDEX=6
        MNTLIST_OPTIONS_INDEX=5
    }

# print "fstypes:", allfstypes|"cat 1>&2"
        split(allfstypes,fstypesTableItems," ")
        for (fs=1; fs <= length(fstypesTableItems); fs++)
        {
 #print "registering fs type:", fstypesTableItems[fs]|"cat 1>&2"
                fstypesTable[fstypesTableItems[fs]]=fstypesTableItems[fs]
        }
        split(allsoftdevtypes,allsoftdevtypesTableItems," ")
        for (fs=1; fs <= length(allsoftdevtypesTableItems); fs++)
        {
#print "registering dev type:", allsoftdevtypesTableItems[fs]|"cat 1>&2"

                allsoftdevtypesTable[allsoftdevtypesTableItems[fs]]=allsoftdevtypesTableItems[fs]
        }

        currentDeviceLocation=exec("findmnt -n \"/\" -o SOURCE")
        currentWorkingDirectory=exec("pwd")

        nbTableCols=split(columnsTitles,columnsTitlesItems," ")
        for (i=1;i<=nbTableCols;i++) { maxColWidths[i-1]=length(columnsTitlesItems[i])  }

        #readFullMountList()
        nbMountLines=split(fullMountList,mountListItems,"\n")
        count=0

        for (i=1;i <= nbMountLines;i++)
        {
                mountListItem = mountListItems[i]
#print "mount line " mountListItem|"cat 1>&2"

                nbMountLineInfo=split(mountListItem,mountedItemFields,"|")
                for (j=0;j<nbMountLineInfo;j++)
                {
#print "mount line [",i,"]",mountedItemFields[j]|"cat 1>&2"
                        mountLineInfo[i][j]=trim(mountedItemFields[j]) # array of array
                }

                size=trim(mountedItemFields[2])
                device=trim(mountedItemFields[4])
                mntfstype=trim(mountedItemFields[3])
                mountpoint=trim(mountedItemFields[MNTLIST_MOUNTPOINT_INDEX])
                mountOptions=trim(mountedItemFields[MNTLIST_OPTIONS_INDEX])
       # print "for",device,"mount options:", mountpoint, mountedItemFields[4], mountOptions|"cat 1>&2"

                mountLineOptions[mountpoint]=mountOptions
                mountIsReadOnly[mountpoint]=0
                nbMountOptions=split(mountOptions,mountOptionArray,",");   
                for (iter=1; iter <= nbMountOptions; iter++)
                {
                        if (mountOptionArray[iter]=="ro")
                        {
                            mountIsReadOnly[mountpoint]=1
                            break
                        }
                        else if (mountOptionArray[iter]=="rw")
                        {
                                if (size != "stuck")
                                {
                                        # On some systems like Windows, if the share is not configured 
                                        # properly, there is no write possible
                                        if (Net__isUNC(device) || Net__isLogin(device) || startsWith(mntfstype,"fuse."))                        
                                        {
                                                checkCmd="timeout -s SIGKILL 3 " SUMO_DIR "/sumo__checkWritable.sh " device
                                                checkCmdTable[device]=checkCmd
                                                #log_dbg("launching 'print " mountpoint " | " checkCmd "' for device " device)
                                                print mountpoint |& checkCmd                                             
#                                   print "export var=$(mktemp -u -t -p \".\") ; echo -n \"\"|tee \""mountpoint"/$var\" && rm -f \"$var\" && echo OK" |"cat 1>&2"
                                                #res=exec("export var=$(mktemp -u -t -p \".\") ; echo -n \"\"|tee \""mountpoint"/$var\" 2>/dev/null && rm -f \""mountpoint"/$var\" && echo OK")
                                                #if (res != "OK")
                                                #{
                                                #        mountIsReadOnly[mountpoint]=2                                          
                                                #        break
                                                #}
                                        }
                                }
                        }
                }

        }

        #registerNetworkDevices()

        setupAncestor()
}


{ 
 # For old lsblk
 #log_dbg( "'" $1 "' '" $2 "' '" $3 "' '" $4 "' '" $5 "' '" $6 "' '" $7)
 # For new lsblk
 log_dbg( "'" $1 "' '" $2 "' '" $3 "' '" $4 "' '" $5 "' '" $6 "' '" $7 "' '" $8 "' '" $9 "' '" $10 "' '" $11 "' '" $12 "' '" $13)
 #print "'" $1 "' '" $2 "' '" $3 "' '" $4 "' '" $5 "' '" $6 "' '" $7 | "cat 1>&2"
 #print $0| "cat 1>&2"
    spaceShadownChar="§"
    label=escapeSpaces(trim($3),spaceShadownChar)
    size=escapeSpaces(trim($4),spaceShadownChar)
    fstype=escapeSpaces(trim($5),spaceShadownChar)
    storage=""
    original_src=trim($6)
    src=escapeSpaces(original_src,spaceShadownChar)
    mntp=""
    devpath=escapeSpaces(original_src,spaceShadownChar)
    storage=""
    original_devicetype=trim($1)
    devicetype=escapeSpaces(original_devicetype,spaceShadownChar) # actual type of the device
    parentdev=escapeSpaces(trim($2),spaceShadownChar)
    partguid=""
    parttypeguid=""
    hiddenDataCol=""

    if (OLDLSBLK=="n")
    {
        fssize=escapeSpaces(trim($7),spaceShadownChar)
        sizeoccupied=escapeSpaces(trim($8),spaceShadownChar)
        fsavail=escapeSpaces(trim($9),spaceShadownChar)
        mountopt=escapeSpaces(trim($10),spaceShadownChar)
        original_mntp=trim($11)
        devmountpoint=escapeSpaces(original_mntp,spaceShadownChar)
        partguid=trim($12)
        parttypeguid=trim($13)        
    }
    else
    {
        fssize="-"
        sizeoccupied="-"
        fsavail=getDeviceAvailableSpace(original_src)
        mountopt=escapeSpaces(trim($7),spaceShadownChar)
        original_mntp=trim($8)
        devmountpoint=escapeSpaces(original_mntp,spaceShadownChar)
        partguid=trim($9)
        parttypeguid=trim($10)
    }

    isvera=0
    isluks=0
    isdiskfile=0    
    isdiskcloud=0    
    
    devIsNet=(Net__isUNC(original_src) || Net__isLogin(original_src) || Net__isHTTP(original_src) || Net__isCloudDevice(original_src) || Net__isCurlFtpfs(original_src)  || Net__isNFS(original_src))
    devIsAdb=(USB__isAdbDevice(original_src))

    if (devIsAdb)
    {
      log_dbg("Getting Android info may take some time");

      AdbSizeAndAvailableSpace=getAdbSizeAndAvailableSpace("/storage/emulated")
      #log_dbg(AdbSizeAndAvailableSpace);
      nbAdbInfoFields=split(AdbSizeAndAvailableSpace, AdbSizeAndAvailableSpaceAsArray, ",")
      if (nbAdbInfoFields>=1)
      {
        sizeoccupied=AdbSizeAndAvailableSpaceAsArray[1]
        size=AdbSizeAndAvailableSpaceAsArray[1]
        fssize=AdbSizeAndAvailableSpaceAsArray[1]
      }
      if (nbAdbInfoFields>=2)
        fsavail=AdbSizeAndAvailableSpaceAsArray[2]

      log_dbg("Android info successfully retrieved");
    }

    # Handle the specific stuck device notification
    if (size=="stuck")
    {
        stuckdevice[original_src]=1
        size=""
    }
    else
    {
        stuckdevice[original_src]=0
    }

    # Decode the mount options
    isreadonly=0
    split("", mountoptValues) # Reset array
    nbMountOptions=split(mountopt,mountoptArray,",");   
        for (iter=1; iter <= nbMountOptions; iter++)
        {
                if (mountoptArray[iter]=="ro")
                {
                        isreadonly=1
                        break
                }
                idx=index(mountoptArray[iter],"=")
                if (idx > 0)
                {
                        mountoptName=trim(substr(mountoptArray[iter],1,idx-1))
                        mountoptValue=trim(substr(mountoptArray[iter],idx+1))
                        mountoptValues[mountoptName]=mountoptValue
                        #log_dbg("mountoptValue:" mountoptName ":" mountoptValue)
                }
        }



   if (isExcluded(devpath))
   {
        next
   }
  #log_warn("original_mntp : " original_mntp)
  # Process and check the filters and update related variables
    if (length(filtersWereChecked)== 0)   
    {
        filtersWereChecked=1
        for(i=1; i<=nbDeviceFilters; i++)
        {
                filter=deviceFilters[i]
        #print "filter:",filter|"cat 1>&2"
                if (match(filter,"^no")!=0) # explicit exclusion
                {
                        split(filter,negFilter,"no");   
                        if (negFilter[2]=="free") 
                                excludeMountable=1
                }
                else if (filter == "free") 
                        showOnlyMountable=1;
        }
    }
   
   # Perform filtering
   # Note specific options like "free" are still remaining in filter. However, as of today
   # there is no device type "free" known, and so there is no incidence. Invalid names should be 
   # ignored from function 'acceptDeviceType'
    if ( ((length(lbl)>0) && (label!="-") && (lbl!=label)) || ! acceptDeviceType(original_src, devicetype,  deviceFilters, negativeFiltersOnly) ) 
    {
        log_dbg("by passed! src=" src " original_mntp="  original_mntp " filter label='" label "' lbl='" lbl " actual type='" devicetype "'")
        bypass(devpath, original_src,original_mntp)
    }

   if (showOnlyMountable)
   {
        if (length(childMap[devpath]) > 0)
        {
         bypass(devpath, original_src,original_mntp)
        }
   }

   #log_dbg("filter passed' " label " " devpath "' '" size "' '" fstype "' '" src "' '" devicetype "' '" parentdev)

    if (devIsNet)
        hiddenDataCol=hiddenDataCol "| /is network link:yes" 

    # First resolve the mount point before displaying source (e.g. for Vera)
    mntp=devmountpoint #findMountPoint(devpath)
    if (match(original_src,"^" MAPPERDIR "/veracrypt")!=0) 
    {
        # Mount folder of the vera volume should actually now be known. 
        # When, it is an intermediate vera device we are not interested in
        # and there is no mountpoint for it
        if (mntp=="-")
        {
                #bypass(devpath, original_src,original_mntp)            
            storage="VERA"
            isvera=1

        }
        else
        {
            retrievedSlot=trim(Vera__findLabelFromMountPoint(mntp))
            #label=retrievedSlot; # NO

            hiddenDataCol=hiddenDataCol "| slot:" trimAnyRight(retrievedSlot,":")
            storage="VERA"
            isvera=1
        }
    }
    else if (match(original_src,"^/dev/loop")!=0)  # Code is deactivated
    {
            file=fileToDevMap[devpath]
            if (length(file)>0)
            {
                storage=File__extension(file) "/loop"
            }
            else
            {
                storage="loop"
            }
           # Inside, docker, non existent loop are hidden
           # NO: useless since loop are filtered by default
           #if (! fileexist(original_src)) bypass(devpath, original_src,original_mntp)
    }
    else if (match(original_src,"^/dev/nbd[0-9]+$")!=0)  # Code is deactivated
    {
            file=fileToDevMap[devpath]
            if (length(file)>0)
            {
                storage=File__extension(file) "/nbd"
            }
            else
            {
                storage="nbd"    
            }
           # Inside, docker, non existent nbd devices are hidden
           if ((! fileexist(original_src)) && ((length(original_mntp)==0) || (original_mntp=="-")))
                bypass(devpath, original_src,original_mntp)
    }
    else if (fstype=="crypto_LUKS")
    {
            isluks=1
    }

    if (length(showOnlyMountable)>0)
    {
        if ((showOnlyMountable) && ((mntp!="-") || (fstype=="-")))
        {
          bypass(devpath, original_src,original_mntp)
        }
    }
    else if (length(excludeMountable)>0)
    {
        if ((excludeMountable) && (mntp=="-"))
        {
                bypass(devpath, original_src,original_mntp)
        }
    }

    # Check if readonly
    mountIsRO=mountIsReadOnly[original_mntp]

    # Field No1 Label
    if (length(label) == 0) 
    {
            label="-" 
    }

# LVM / udevadm
# E: DM_VG_NAME=riffian-vg
#E: DM_LV_NAME=home

   if (devIsNet)
   {
        storage="inet"
        split("", con_props)
        con_props["host"]=""
        if (Net__getConType(original_src,con_props))
        {
                if (length(trim(con_props["short link mode"])) > 0)
                        storage=con_props["short link mode"]
                else
                        storage="§"
                if (length(trim(con_props["ESSID"])) > 0)
                {
                        label=con_props["ESSID"]
                        updateMaxColWidths(0, label)
                }
                con_props["ESSID,BSSID"]=con_props["ESSID"] "," con_props["BSSID"]
                if (con_props["ESSID,BSSID"]==",") con_props["ESSID,BSSID"]=""
                con_props["ESSID"]=""
                con_props["BSSID"]=""
        }
        excludedProps["supported link modes"]=1
        excludedProps["short link mode"]=1
        excludedProps["path"]=1
        excludedProps["duplex"]=1

        for (key_conprop in con_props)
        {
                if (length(excludedProps[key_conprop])==0)
                        if (length(con_props[key_conprop])>0)
                                hiddenDataCol=hiddenDataCol "| " key_conprop ":" con_props[key_conprop]
        }
   }
   else if (devIsAdb)
   {
        #log_dbg("devIsAdb get version info ");
        androidVersion=getAdbVersion()
        androidSdkVersion=getAdbSdkVersion()
        storage="Android§" androidVersion
        adbDeviceStatus=USB__getAdbDeviceStatus(original_src);
        # If adb device is not mounted, it means it was manually
        # inserted where the label holds the name of the device
        if (original_mntp=="-") 
        {
                androidDeviceName=label # androidDeviceName not used in that context at the moment
                # NO : if (length(adbDeviceStatus)>0) mntp=adbDeviceStatus;
        }
        else
        {
                androidDeviceName=getAdbDeviceName()
                label=androidDeviceName               
        }
        #src="adb://usb:" androidDeviceName
        if (length(adbDeviceStatus)>0) 
                src="adb://usb" "§(" adbDeviceStatus ")" ;
        else
                src="adb://usb" adbDeviceStatus;
        hiddenDataCol=hiddenDataCol "| " "Android version" ":" androidVersion
        hiddenDataCol=hiddenDataCol "| " "Android SDK version" ":" androidSdkVersion        
        hiddenDataCol=hiddenDataCol "| " "Device name" ":" androidDeviceName
   }
   else
   {
        # No2 storage type
        # This one below does not work
        devadmInfoFields["E: ID_BUS"]="-"
        devadmInfoFields["E: DEVTYPE"]="-"
        devadmInfoFields["E: ID_VENDOR"]="-"
        devadmInfoFields["E: ID_MODEL"]="-"
        devadmInfoFields["E: ID_MODEL_ID"]="-"
        devadmInfoFields["E: ID_VENDOR_ID"]="-"
        devadmInfoFields["E: ID_USB_DRIVER"]="-"
        devadmInfoFields["E: ID_SERIAL"]="-"
        devadmInfoFields["E: ID_PATH"]="-"
        
        getDeviceInfoRange(original_src, devadmInfoFields)
        ID_BUS=devadmInfoFields["E: ID_BUS"]
        ID_DEVTYPE=devadmInfoFields["E: DEVTYPE"]

        # Cleanup not found props
        for (key_prop in devadmInfoFields) { if (devadmInfoFields[key_prop]=="-") devadmInfoFields[key_prop]="" }

#print "storage", storage, ", devadm!!!! ", ID_BUS, ID_DEVTYPE|"cat 1>&2"

        if (storage == "VERA")  # TODO TEST IF VERA ON ACTUAL DEVICE (eg USB)
        {
                if (ID_BUS!="-")
                {
                        storage="VERA/"ID_BUS; # TO test 
                }
        }
        else if (index(storage,"nbd") || index(storage,"loop"))
        {
                if (ID_BUS!="-")
                {
                        storage="VERA/"ID_BUS;# TO test 
                }
        }
        else
        {
                if (ID_DEVTYPE=="disk")     
                {
                        storage=toupper(ID_BUS);

                        if (storage=="USB") hiddenDataCol=hiddenDataCol "| " "usb version" ":"  getUSBVersion(devpath, devadmInfoFields["E: ID_VENDOR_ID"], devadmInfoFields["E: ID_MODEL_ID"]) 

                        if (!isValidSoftDeviceType(original_devicetype))
                        {
                                hiddenDataCol=hiddenDataCol "| " "vendor" ":" devadmInfoFields["E: ID_VENDOR"]
                                hiddenDataCol=hiddenDataCol "| " "model" ":" devadmInfoFields["E: ID_MODEL"] devadmInfoFields["E: ID_MODEL_ID"]
                                hiddenDataCol=hiddenDataCol "| " "serial" ":" devadmInfoFields["E: ID_SERIAL"]
                                hiddenDataCol=hiddenDataCol "| " "path" ":" devadmInfoFields["E: ID_PATH"]
                        }

                        if (storage=="USB")
                        {
                             hiddenDataCol=hiddenDataCol "| " "driver" ":" devadmInfoFields["E: ID_USB_DRIVER"]
                             storage=storage "." getUSBVersion(devpath, devadmInfoFields["E: ID_VENDOR_ID"], devadmInfoFields["E: ID_MODEL_ID"])   
                        }
                }
                else
                {
                        storage=ID_DEVTYPE;
                }
        }

        if (tolower(storage)=="partition")
                storage="part"
        else if (storage=="-")
                storage=devicetype

        if (length(storage)==0) storage="-";
   }

    if (isreadonly==1)
            storage=storage "(ro)"

    # No3 size
    if (length(size)==0) size="-";

    # No4 available space
    avail=fsavail

    # No5 filesystem type
    if (length(fstype)==0) fstype="-"; 

    # No6 Boot type
    boottype=getBootType(original_src)
    boottype=escapeSpaces(boottype,spaceShadownChar)

    # No7 source/device path
    #src_is_root=1
    file=""
    if (length(src) > 0)
    {
        if (startsWith(original_src,"curlftpfs#"))
        {
                pat="^curlftpfs#"
                gsub(pat, "", src)
        }
        else if (fstype=="overlay")
        {
                #mountoptValues["lowerdir"]="testLower:TestLowest" # For testing Multi-lowerdir case
                overlayLowerDir=basename(mountoptValues["lowerdir"])
                overlayUpperDir=basename(mountoptValues["upperdir"])
                if (index(mountoptValues["lowerdir"],":") > 0)
                {
                        # Multi-lowerdir case, where the lowest layers have to be read from right to left
                        nbLowerDirs=split(mountoptValues["lowerdir"], overlayLowerDirs, ":")
                        overlayLowerDir=basename(overlayLowerDirs[1])
                        for (i=2; i<=nbLowerDirs;i++)
                        {
                                overlayLowerDir=overlayLowerDir ">" basename(overlayLowerDirs[i])
                        }
                }
                src=escapeSpaces(overlayUpperDir ">" overlayLowerDir,spaceShadownChar)
                # "\\U2283 " is math superset symbol but printTable handles only printing of starting unicode char
        }
        else
        {
                file=fileToDevMap[devpath]
                if (length(file)>0) 
                {
                        src=basename(file)

                        if (isluks) storage="LUKS"
                        isdiskfile=1
                }
                else if (Net__isCloudDevice(original_src))
                {
                        url_props["host"]=""
                        Net__decodeHTTP(Net__getCloudURLFromDevice(original_src), url_props)
                        src=url_props["host"]
                        isdiskcloud=1
                }
                else if (Net__isHTTP(original_src))
                {
                        src=original_src
                        isdiskcloud=1
                }

                # print devpath, " is isdiskcloud ", isdiskcloud , " file path:",fileToDevMap[devpath]|"cat 1>&2"

                # Indentation for child devices is inserted at the end of the processing of all items, where all excluded items are known
        }
    }
    else 
    {
            src="-"
    }

   # No 8 Status
    mnt_status="" # \\U2713" # 

    # No9 mountmoint
    # and status depending of the type of the mount and the hierarchy
    if ( (length(HOME)>0) && (length(HOME_REPLACE)>0) )
        gsub(HOME,HOME_REPLACE, mntp)

    if (! stuckdevice[original_src]) 
    { 
        _originalMntpForTest=mntp
        mntp=toRelativePathToHome(mntp) 
        if (length(mntp) >= length(_originalMntpForTest))
               mntp=_originalMntpForTest
    }
    mntp=escapeSpaces(mntp,spaceShadownChar)

    if (stuckdevice[original_src]) 
    {
        hiddenDataCol=hiddenDataCol "| status: stuck"
        # this is set hereafter as final step.
        # however, since the stuck test has precedence over other statuses, it could
        # be set from herE. TODO: check later if this can be uncommented by reviewing
        # code below
        # mnt_status="\\U2715" 
    }
    else if (mountIsRO==1)
    {
        mnt_status="\\U20E0\\U20" # \\U270E"  #colored "\\U1F6AB" #"\\U1F511" #"\\U2300"  #"\\U1F512"
        hiddenDataCol=hiddenDataCol "| status: read-only"
    }
    else if (mountIsRO==2)
    {
        mnt_status="\\U26A0\\U270E"
        hiddenDataCol=hiddenDataCol "| status: r/w mounted, but not writable"
    }

    # We explicitly avoid to use '-' for displayed mountpoint (since '-' could be a valid folder)
    if (mntp=="-") mntp="§"

    if (!devIsNet && !devIsAdb)
    {
        if ((storage!="part") && (!isdiskfile) && (!isdiskcloud))
        #if ((storage!="part") && (!isdiskfile) && (!isdiskcloud) && (length(ancestorMap[devpath])==0))
        {
          # Check for disk and hardware device to put specific icons in the status and specific hidden data
          if ((length(nbChilds[devpath]) > 0) && (nbChilds[devpath]>1)  )
          {
                # @deprecated , it may always be possible to batch mount/unmount from a top device
                #hiddenDataCol=hiddenDataCol "| status: not mountable"

                #mnt_status="\\U2717" # @deprecated ,NOT USED

                #if (length(mnt_status)==0) 
                if ((length(mnt_status)==0) && (length(ancestorMap[devpath])==0))
                {
                        mnt_status="\\U26C1" # 2715"  # 274C" #2613" # 3 disks icons
                        hiddenDataCol=hiddenDataCol "| format:yes"
                }

                rootAncestor=getVisibleAncestor(currentDeviceLocation,1)
                if (rootAncestor==devpath)
                {
                        label="localhost"
                        updateMaxColWidths(0, label)
                        hiddenDataCol=hiddenDataCol "| information: this is the mass storage of your localhost."
                        mainHostname=exec("hostname")
                        if (length(mainHostname)>0) hiddenDataCol=hiddenDataCol "| hostname: " mainHostname
                        split("",ipaddr_dev)
                        split("",ipaddr_ip)
                        split("",ipaddr_mac)
                        nbIfacesFound=Net__ipaddr_getInterfaces(ipaddr_dev,ipaddr_ip,ipaddr_mac)
                        for (i=1;i<=nbIfacesFound;i++)
                        {
                            hiddenDataCol=hiddenDataCol "| LAN interface " i ": IP=" ipaddr_ip[i] " MAC=" ipaddr_mac[i] " device=" ipaddr_dev[i]
                        }
                }
          }
          else
          {
                if (!isValidSoftDeviceType(original_devicetype) && (fstype!="overlay"))
                {
                        if (length(mnt_status)==0) 
                        {
                                if (startsWith(storage,"USB"))
                                {
                                        mnt_status="\\U257E" 
                                }
                                else
                                {
                                        mnt_status="\\U26C0" # single disk icons
                                }
                        }
                                                
                        hiddenDataCol=hiddenDataCol "| format:yes"
               }
          }
        }
        else if (isdiskfile)
        {
                hiddenDataCol=hiddenDataCol "|" "full disk file path:" "\""file"\"" "|" "system device:" devpath
        }

         # if (src_is_root) # mnt_status="\\U2690"
        if (original_src==currentDeviceLocation) 
        {
                mnt_status="\\U2302" # \\U0020"  # \\U0020 2690"
                hiddenDataCol=hiddenDataCol "|" "description" ":" "this is the root folder below which all mount points are located."
        }
    }
    else
    {
        if (devIsAdb)
        {
            hiddenDataCol=hiddenDataCol "|" "/real source:adb://usb"  "|" "system device:" devpath

        }
        else if (isdiskcloud)
        {
            if ((mnt_status=="§") || (length(mnt_status)==0)) 
                mnt_status="\\U2601"
                # shadown circle "\\U274D"
                # globus "\\U1F310"

            url_props["host"]=""
            #Net__decodeHTTP(Net__getCloudURLFromDevice(original_src), url_props)
            #log_warn("DECODED HTTP ADDR: '" url_props["host"] "'")
            hiddenDataCol=hiddenDataCol "|" "/real source:" "\"" Net__getCloudURLFromDevice(original_src) "\"" "|" "system device:" devpath
        }
        else
        {
            if ((mnt_status=="§") || (length(mnt_status)==0)) 
            {
                if (length(trim(con_props["ESSID,BSSID"])) > 0)
                        mnt_status="\\U1F4F6"  #"\\U1F6DC" 
                else
                        mnt_status="\\U252F" # "\\U237D" # Ethernet symbol
                # T : U2566
                # rectangle: "\\U25AD
            }
        }
    }

   embeddingDiskFile=findEmbbedingDisk(devpath)
   if (length(embeddingDiskFile) > 0)
   {
        hiddenDataCol=hiddenDataCol "|" "embedding disk file path:" "\"" embeddingDiskFile "\""
   }
   
   #if (src_is_root)
   #{
   #     hiddenDataCol=hiddenDataCol "|" "is root: yes"
   #}

   # Some systems having 1 child, allow unmounting from parent
   # log_dbg("nbChild for " devpath " is "  nbChilds[devpath])
   lastDescendantOnlyChild=findOnlyChildLastDescendant(devpath)
    if ((length(lastDescendant) > 0) && 
        (!devIsNet) && (!devIsAdb)  ) # && (!isdiskfile))
    {
        hiddenDataCol=hiddenDataCol "|" "/delegate-device" ":" lastDescendantOnlyChild "|" "/delegate-mountpoint" ":" mountpointMap[lastDescendantOnlyChild] "|" "/delegate-status" ":" mountIsReadOnly[mountpointMap[lastDescendantOnlyChild]]
    }

    if (hasMountedChilds[devpath]) 
    {
        hiddenDataCol=hiddenDataCol "|" "/has-mounted-child" ": yes" 
    }
   
   duplicateFormat=""

   if (stuckdevice[original_src]) 
   { 
        mnt_status="\\U2715" 
        duplicateFormat="\033[1;31m"
   }

   if (length(mnt_status)==0) mnt_status="§"

   # Truncate source and mount point string if necessary
   # Note 'src' is the displayed source whereas original_src is the true value
   # max_len_src_string=30 
   # max_len_mntp_string=30 
   if (max_len_src_string)
        src=truncateMid3Dots(src, max_len_src_string)
   if (max_len_mntp_string)
        mntp=truncateMid3Dots(mntp, max_len_mntp_string)


  hiddenDataCol=hiddenDataCol "|" "label" ":" label
  # Fill the mountsource hidden field. This is the real data source location 
  # as expected by the master bash app. It is used as key for the RECENT[] map
  # which is used to save the recent.yml
  #
  # For SSH and SAMBA/UNC, the system device is already OK both for display and Internal
  # RECENT[]
  #
  # in future , 'real source 'should be used and mountsource should be the 
  # original system device

  if (startsWith(fstype,"nfs"))
  {
    # For NFS, the system device must just be completed with nfs://
    # What is displayed is however still the system device, because it is enough
    # since the fstype is also displayed.
    hiddenDataCol=hiddenDataCol "|" "/mountsource" ":" "nfs://" original_src
    hiddenDataCol=hiddenDataCol "|" "/real source:" "nfs://" original_src "|" "system device:" devpath
  }
  else if (startsWith(original_src,"curlftpfs#"))
  {
    # For FTP, curlftp# must be removed from original system device
    # but this is already done for 'src' used for the actual display
    hiddenDataCol=hiddenDataCol "|" "/mountsource" ":" src
    hiddenDataCol=hiddenDataCol "|" "/real source:" src "|" "system device:" devpath
  }
  else
  {
    hiddenDataCol=hiddenDataCol "|" "/mountsource" ":" original_src
  }

  hiddenDataCol=hiddenDataCol "|" "mountpoint" ":" original_mntp
  if ((original_mntp!="-") && !startsWith(original_mntp,"/"))
  {
        hiddenDataCol=hiddenDataCol "|" "mountpoint_realpath" ":" exec("realpath -m " original_mntp)
  }
  else if (isdiskfile && hasMountedChilds[devpath] && (nbChilds[devpath] > 1)) 
  {
        # Search for the first mounted child
        # TODO/NOTE: this was initially introduced to resolve the mountdir of the top item corresponding to a QCOW2 disk file
        # However, this works only if an immediate child is mounted. If there is a further indirection like LVM2 member, 
        # this algorithm must be improved
        firstMountedChild=childMap[devpath] # default uses value
        for (device in ancestorMap) {
                # if (ancestorMap[device]==devpath) print "isdiskfile: found ancester", device |"cat 1>&2"   
                if ((ancestorMap[device]==devpath) && (length(mountpointMap[device])>0))
                {
                        firstMountedChild=device
                        break
                }
        }
        diskMountDir=exec("realpath -m $(dirname \"" mountpointMap[firstMountedChild] "\")")
        hiddenDataCol=hiddenDataCol "|" "mountpoint_realpath" ":" diskMountDir  #" =>" firstMountedChild
        mntp=toRelativePathToHome(diskMountDir)
        # print "isdiskfile:", devpath, " nb children:", nbChilds[devpath],firstMountedChild,mountpointMap[firstMountedChild],diskMountDir,mntp  |"cat 1>&2"   
  }

  myancestorDev=getVisibleAncestor(devpath,0) # actually returns the direct parent (not excluded)
  if (myancestorDev!="")
  {
        file=fileToDevMap[myancestorDev]
        if (length(file)>0) 
                hiddenDataCol=hiddenDataCol "|" "/parentmountsource" ":" file
        else
                hiddenDataCol=hiddenDataCol "|" "/parentmountsource" ":" myancestorDev

        hiddenDataCol=hiddenDataCol "|" "/parentmountpoint" ":" mountpointMap[myancestorDev]
  }

  if ((original_mntp=="-") || (length(original_mntp)==0))
        mountopt="-"
  else
        mountopt=mountLineOptions[original_mntp]
  hiddenDataCol=hiddenDataCol "|" "mount options" ":" mountopt

  # Look for the actual partition type
  if (tolower(storage)=="part")
  {
        #_parttype=getPartitionType(original_src)
        storage=getPartitionTypeName(parttypeguid);
        storage=escapeSpaces(storage,"§")

        hiddenDataCol=hiddenDataCol "|" "partition type GUID" ":" parttypeguid
        hiddenDataCol=hiddenDataCol "|" "partition GUID" ":" partguid

        testFsType=tolower(fstype)
        testPartTypeName=tolower(storage)
        if (startsWith(testPartTypeName,"fat"))
        {
                if ((testFsType!="vfat") && (testFsType!="exfat") && (testFsType!="ntfs") && !startsWith(testFsType,"fat"))
                {
                        duplicateFormat="\033[1;31m"
                        hiddenDataCol=hiddenDataCol "| warning: part type " testPartTypeName " inconsistent with fs type " fstype "."
                }
        }

        #log_dbg("storage is '" storage "', parttype:'" _parttype "'")
  }

   hiddenDataCol=escapeSpaces(hiddenDataCol,"§")

   #log_dbg(hiddenDataCol)
   #print devpath, "mntp:",mntp, "mysrc and hiddenDataCol:",src,hiddenDataCol, isExcluded(devpath)|"cat 1>&2"

     # From here on, set up the actual displayed output lines
     # except those excluded by the filtersWereChecked
     # Take care sumo_lib.awk:acceptDevice marks top nbd device like nbd0 as excluded, even though it 
     #if (isExcluded(devpath))  # activate this when 'next' is not called from bypass
     #   next

     addOutputAtEnd=1
     # Check if if there are no multiple mounts
     for (i=0; i < nbMountLines; i++)
     {
        #print "scanning mount list",devpath,trim(original_mntp), mountLineInfo[i][4],  mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX] |"cat 1>&2"
        if (mountLineInfo[i][4]==original_src) # 4 == source
        {
                # Insert an entry for the duplicate item
                if (mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX]!=trim(original_mntp)) # 9 == mount point
                {
                        #log_dbg("found duplicate mount " original_src "'" mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX] "' '"  trim(original_mntp) "'")

                        duplicateFormat="\033[1;31m"
                        #if (!Net__isUNC(original_src) && !Net__isLogin(original_src))
                        # The duplicate insertion is only valid for those mount handled by lsblk
                        # For all others no, since the mounts are retrieved from findmnt
                        if (!devIsNet && !devIsAdb && (fstype!="overlay"))
                        {
                                # 2025.01.27/Ubuntu20: lsblk does not report multiple mounts
                                if (length(duplicatedInserted[mntp])== 0) # if multiple mounts, avoid inserting multiple times our original mount
                                {
                                        newHiddenDataCol=hiddenDataCol "|" "duplicate mount:" mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX]  
                                        newHiddenDataCol=escapeSpaces(newHiddenDataCol,"§")
                                        addOutputData(devpath, file, duplicateFormat, label, storage, size, avail, fstype, boottype, src, mnt_status, mntp, newHiddenDataCol)     
                                        duplicatedInserted[mntp]=src

                                        # update hiddenData for the duplicate
                                        hiddenDataCol=hiddenDataCol "|" "duplicate mount:" original_mntp
                                        hiddenDataCol=escapeSpaces(hiddenDataCol,"§")
                                }

                                addOutputData(devpath, file, duplicateFormat, label, storage, size, avail, fstype, boottype, src, mnt_status, escapeSpaces(toRelativePathToHome(mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX]),spaceShadownChar) , hiddenDataCol)
                                # addOutputData(devpath, file, duplicateFormat, "§", "§", "§", "§", "§", "§", src, "§", escapeSpaces(mountLineInfo[i][MNTLIST_MOUNTPOINT_INDEX],spaceShadownChar) , newHiddenDataCol)     
                                addOutputAtEnd=0                                
                        }
                        else
                        {
                                #label="§";storage="§";size="§";avail="§";fstype="§";boottype="§" # No, otherwise none shows any info
                        }
                }
        }
     }
     if (addOutputAtEnd) addOutputData(devpath, file, duplicateFormat, label, storage, size, avail, fstype, boottype, src, mnt_status, mntp, hiddenDataCol)     

     registerProcessedDevice(devpath,original_mntp) 
}
END {
        # Order the lines to match device hierarchy
        for (i=0;i < nbProcessedDevices;i++)
        {
                devpath=processedDevices[i]
                hiearchyLevel[devpath]=getNbAncestors(devpath)
                #print "hierachy level for", devpath,":", hiearchyLevel[devpath] | "cat 1>&2"
                outputFinal[i]=""
                newOutputDev[i]=""
        }

        nextIndex=0
        hierarchyLevel=0        
        rebuildLineHierarchy(0, "", hierarchyLevel)

        # Handle the orphans
        deepestOrphanHierarchyLevel=0
        for (i=0;i < nbOutputData;i++)
        {
                if (length(outputDev[i])>0) 
                {
                        if (hiearchyLevel[outputDev[i]] > deepestOrphanHierarchyLevel)
                        {
                                deepestOrphanHierarchyLevel=hiearchyLevel[outputDev[i]]
                        }
                }
        }
        #        print "orphane",deepestOrphanHierarchyLevel|"cat 1>&2"  
        for (i=0;i < deepestOrphanHierarchyLevel;i++)
        {
                hierarchyLevel=hierarchyLevel+1
                rebuildLineHierarchy(0, "", hierarchyLevel)
        }

        for (i=0;i < nbOutputData;i++)
        {
                devpath=newOutputDev[i]
                dataIndexes=newOutputDevIndex[devpath]
                nbDataIndexes=split(dataIndexes,dataIndexArray," ")
                for (dataIndexIter=1;dataIndexIter<=nbDataIndexes;dataIndexIter++)
                {
                        dataIndex=dataIndexArray[dataIndexIter]

                        # Add the indentation
                        output_data_src[dataIndex]=addHierarchyIndent(devpath, output_data_src[dataIndex])

                        # Waiting for the write test
                        checkCmd=checkCmdTable[devpath]
                        #log_dbg("wait for the check for " devpath ", CMD: '" checkCmd "'")
                        if (length(checkCmd) > 0)
                        {
                                #log_dbg("CHECK CMD: '" checkCmd "'")
                                wrPollRes=""
                                checkCmd |& getline wrPollRes
                                #log_dbg("CHECK CMD result: '" wrPollRes "', current mntstatus: '" output_data_mntstatus[dataIndex] "'")
                                if (wrPollRes != "OK")
                                {
                                        if (length(output_data_mntstatus[dataIndex]) > 0)
                                        {
                                                output_data_mntstatus[dataIndex]="\\U26A0\\U270E" 
                                                output_data_hidden[dataIndex]=output_data_hidden[dataIndex] "|§status:§r/w§mounted,§but§not§writable"
                                        }
                                }
                        }

                        # Construct and stopre the final output line along with updated statistics
                        addOutputLineFromIndex(dataIndex)
                }
        }

        #
        # Print all the final list 
        #

        # Print the data header
        headerInfo=maxColWidths[0]" "maxColWidths[1]" "maxColWidths[2]" "maxColWidths[3]" "maxColWidths[4]" "maxColWidths[5]" "maxColWidths[6]" "maxColWidths[7]" "maxColWidths[8]
        lineWidth=0
        for (i=0;i<nbTableCols;i++) 
                lineWidth=lineWidth+maxColWidths[i]+1
        print lineWidth,headerInfo

        # Print the actual data lines
        for (i=0;i < nbOutputFinal;i++)
        {
                devpath=newOutputDev[i]
                #dataIndex=newOutputDevIndex[devpath]
                print outputFinal[i]
        }

        # Print the filtered items which are not visible
        for (ignoredMountedDevice in ignoredMountedDevices)
        {
                if (length(ignoredMountedDevice) > 0)
                {
                        outputLine="/ignore:" ignoredMountedDevice "|" ignoredMountedDevices[ignoredMountedDevice]
                        outputLine=escapeSpaces(outputLine,spaceShadownChar)                
                        print outputLine
                }
        }

        # Add the details, which will be visible depending 
        # on the 'all' option for -l or -i
#        cnt=1
#        first=1
#        printf "DETAILS§§\n"
#        while (length(processedDevices[cnt]) > 0)
#        {
#                devpath=processedDevices[cnt]
#                if (length(mapDevPathFilePath[devpath]) > 0)
#                {
#                        if (first)
#                        {
#                                first=0
#                                printf "\n"
#                                printf "\\\\Internal system devices for disk files:\n"
#                                printf "\n"
#                        }
#                        file=mapDevPathFilePath[devpath]
#                        printf("\\\\%s", devpath)
#                        if (length(devpath)<30)
#                        {
#                                diff=30-length(devpath)
#                                for (i=1; i <= diff; i++)
#                                {
#                                        printf(" ");
#                                }
#                        }
#                        printf("%s\n", file)
#                }
#                cnt=cnt+1
#        }
}

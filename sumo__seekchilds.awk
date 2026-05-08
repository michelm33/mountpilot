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
# Release file path: sumo__seekchilds.awk
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-03-11 23:10:02.287090524 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# Report bugs to michel.mehl@slashetc.fr
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

function searchAndPrintAncestorForChild(devpath)
{   
        level=0
        mntp=mountpointMap[devpath]
        a=ancestorMap[devpath]
        #log_dbg("ancestor for child " devpath " is : '" a "' mntp:'" mntp "'")
        while (length(a) > 0) 
        {
                if ((a==param_ancestor) && (length(mntp)>0))
                {
                    log_dbg("FOUND child " devpath " is : '" a "' mntp:'" mntp "'")
                    # In case the found child is a file, check that it is located below the ancestor's mntp
                    file=fileToDevMap[devpath]
                    if (length(file)>0) 
                    {
                        foundChildSrcIsBelowAncestor=0
                        if (startsWith(file, param_ancestor_mntp))
                        #if ((length(mntp) > 1) && (length(file)>length(mntp))) # to exclude "/"
                        {
#                            leadingPath=substr(file,1, length(mntp))
#                            firstCharAfterLeadingPath=substr(file,length(mntp)+1, 1)
#                            print "key match",key,mountPoint,"leadingpath",leadingPath,"first char",firstCharAfterLeadingPath|"cat 1>&2"
#                            if ((firstCharAfterLeadingPath=="/") && (leadingPath == mountPoint))
#                            {
                                log_dbg("FOUND child " devpath " with correct mntp!")
                                foundChildSrcIsBelowAncestor=1
#                            }
                        }
                    }
                    else
                    {
                        foundChildSrcIsBelowAncestor=1
                    }

                    if (foundChildSrcIsBelowAncestor)
                    {
                        #log_dbg("found  ancestor for child" devpath  "which is " a)
                        printf("|%s|%s|%s|%s\n",level,devpath,fileToDevMap[devpath],mntp) 
                        return 1 # we found it, devpath is a valid child of ancestor
                    }
                }
                level=level+1
                a = ancestorMap[a]    
        }
}

function printChildsForAncestor()
{
        for (i=1; i <=nbLinesAncestry; i++ )
        {
            # print ancestorEntries[i]|"cat 1>&2"
            nbFields=split(ancestorEntries[i],entryFields," ")
            if (nbFields >= 3)
            {
                devpath=entryFields[nbFields]
                #log_dbg("printChildsForAncestor child device:" devpath)
                searchAndPrintAncestorForChild(devpath)
            }
        }
}

{
    doGetFilenamesForAllDevices=1

    # Initialize the filters
    nbDeviceFilters=0
    deviceFilters=""
    negativeFiltersOnly=0

    getLoopBackFiles()  # initializes global array 'loopBackFile'
    getNBDBackFiles()   # initializes global array 'nbdBackFile'
    getVERABackFiles()  # initializes global array 'mapVeraDeviceMappers'

    log_dbg("ancestor param:'"  param_ancestor "', '" param_ancestor_mntp "'")

    setupAncestor()
    printf("%s\n", mapDevPathFilePath[param_ancestor])
    printChildsForAncestor()
}

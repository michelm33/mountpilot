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
# Release file path: sumo__checkWritable.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-11-16 23:15:32.136140075 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This script is used to check that a mounted data source is writeable. It is 
# called from Sumo__list.awk while retrieving the list of mounted data sources.
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

if [ $# -eq 1 ] ; then
    read mountpoint
    touch "$mountpoint/.sumo_poll" 2>/dev/null && echo OK # >>  "log_checkwritable.txt"
    exit 0
else
    exit 1
fi


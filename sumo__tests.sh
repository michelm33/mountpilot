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
# Release file path: sumo__tests.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2025-02-28 10:32:02.610438615 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file is dedicated to testing of SUMO
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
This function implements the test cases for the main sumo functions
@param [1] the full string given as value to -o option.
EOF

Sumo__testCase()
{
        local testCase="$1"
        local res=1
        _log_dbg "--- --- Creating test folder test_sumo" 
        mkdir test_sumo &>/dev/null
        pushd test_sumo &>/dev/null

        case $testCase in
        0|img)               
                _test "Creating a plain disk image of size 10 MiB with label mydisk" 0 "" sumo disk.img -y -o size=10M -L mydisk
                _test "Write a test file in the mounted disk image" 0 "" 'echo "test string" > disk/test.txt'
                _test "Unmounting from disk image file" 0 "" sumo -u disk.img
                _test "Remounting with disk image file" 0 "" sumo disk.img
                _test "Check content of test file" 0 "" 'read var< <(cat disk/test.txt) && [ "$var" == "test string" ]'
                _test "Unmounting from mount folder" 0 "" sumo -u ./disk
                _test "Remounting with disk image file" 0 "" sumo disk.img
                _test "Unmounting from volume label" 0 "" sumo -u -L mydisk
                _test "Remounting with disk image file" 0 "" sumo disk.img
                local devPath=("unused" "/dev/loop23p1")
                if [ ${__SHELL_TEST_GEN_EXAMPLES__} -ne 0 ] ; then
                        devPath=($(Sumo__resolveMountingInfosFromDiskFile "$(realpath "./disk.img")"))
                fi
                _test "Unmounting from block device" 0 "" sumo -u "${devPath[1]}"
        ;;
        1|luks)
                _test "Creating a LUKS disk image of size 50 MiB with label myencryptedvol" 0 "" sumo encrypted_disk.luks -y -p mypassword -o size=50M -L myencryptedvol
                _test "Write a test file in the mounted disk image" 0 "" 'echo "test string" > encrypted_disk/test.txt'
                _test "Unmounting from disk image file" 0 "" sumo -u encrypted_disk.luks
                _test "Remounting with disk image file" 0 "" sumo encrypted_disk.luks -p mypassword
                _test "Check content of test file" 0 "" 'read var< <(cat encrypted_disk/test.txt) && [ "$var" == "test string" ]'
                _test "Unmounting from mount folder" 0 "" sumo -u ./encrypted_disk
                _test "Remounting with disk image file" 0 "" sumo encrypted_disk.luks -p mypassword
                _test "Unmounting from volume label" 0 "" sumo -u -L myencryptedvol
                _test "Remounting with disk image file" 0 "" sumo encrypted_disk.luks -p mypassword
                local devPath=("unused" "/dev/mapper/encrypted_disk")
                if [ ${__SHELL_TEST_GEN_EXAMPLES__} -ne 0 ] ; then
                        devPath=($(Sumo__resolveMountingInfosFromDiskFile "$(realpath "./encrypted_disk.luks")" "luks"))
                fi
                _test "Unmounting from block device" 0 "" sumo -u "${devPath[1]}"
        ;;
        2|vera)
                _test "Creating a vera disk image of size 20 MiB" 0 "" sumo encrypted_disk.vera -y -p mypassword -o size=20M
                _test "Write a test file in the mounted disk image" 0 "" 'echo "test string" > encrypted_disk/test.txt'
                _test "Unmounting from disk image file" 0 "" sumo -u encrypted_disk.vera
                _test "Remounting with disk image file" 0 "" sumo encrypted_disk.vera -p mypassword
                _test "Check content of test file" 0 "" 'read var< <(cat encrypted_disk/test.txt) && [ "$var" == "test string"' ]
                _test "Unmounting from mount folder" 0 "" sumo -u ./encrypted_disk
                _test "Remounting with disk image file with volume label 3" 0 "" sumo encrypted_disk.vera -p mypassword -L 3
                _test "Unmounting from volume label" 0 "" sumo -u "-L 3"
        ;;
        errors)
                _test "Invalid option -size" 1 "" sumo disk.img -y -size=1M
                _test "Label longer than 16 chars" 1 ""  sumo encrypted_disk.luks -y -p mypassword -o size=50M -L myencryptedvolume
                #_test "Mounting not existing disk image file" 0 "" sumo disk_well_unknown.img
                ;;
        *)      
                return 100 # this signals we arrived at the end
        ;;
        esac
        res=$?

        popd &>/dev/null
        _log_dbg "--- --- Removing test folder test_sumo"  
        rm -rf ./test_sumo &>/dev/null

        return $res # Test case success
}


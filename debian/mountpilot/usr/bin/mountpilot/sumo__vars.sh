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
# Release file path: sumo__vars.sh
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.2
# Source file last modification: 2026-05-07 19:20:33.722787571 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# This file contains the definition of all variables supported by SUMO.
# Part of these variables are also controllable via the YAML configuration file.
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


read -r SUMO__VARS["SUMO__VERSION"] < <(cat "${SUMO__VARS["SUMO__MY_DIR"]}/VERSION.txt")

if [ -v USER ] ; then
    SUMO__VARS["OWNER"]="${USER}"  # Avoids running a subshell
else
    read SUMO__VARS["OWNER"] < <(id -u -n)
fi
SUMO__VARS["MOUNT__CIFS"]=""
SUMO__VARS["DEV"]=""
SUMO__VARS["DEVPART"]=""
SUMO__VARS["DEVPART_TYPE"]=""
SUMO__VARS["DEVMAPPER"]=""
# DEVTYPE is historically used to store the whole filter options for listing
SUMO__VARS["DEVTYPE"]=""
SUMO__VARS["DISABLE_HISTORY"]=false
SUMO__VARS["HISTORY_GHOST"]=false

SUMO__VARS["IMG_FILE"]=""
SUMO__VARS["IMG_DISK_FILE_PATH"]=""     # Contains absolute path of a passed disk file while mounting
SUMO__VARS["IMG_FILE_IS_BLK_DEV"]=1     # Default: no

# Overlay
SUMO__VARS["LOWER_DIRS"]=""


# For network based mounting
#SUMO__VARS["IMG_FILE_IS_URL"]=1     # do not define, code relies on existence test of variable
#SUMO__VARS["IMG_FILE_IS_CLOUD_URL"]=1     # do not define, code relies on existence test of variable
SUMO__VARS["IMG_FILE_IS_UNC"]=1     # Default: no
SUMO__VARS["IMG_FILE_IS_LOGIN"]=1     # Default: no
SUMO__VARS["IMG_FILE_IS_HTTP"]=1     # Default: no
SUMO__VARS["NET_PROTO"]=""
SUMO__VARS["NET_LOGIN"]=""
SUMO__VARS["NET_IP"]=""
SUMO__VARS["NET_HOST"]=""
SUMO__VARS["NET_HOSTNAME"]=""
SUMO__VARS["NET_SHARE"]=""
SUMO__VARS["NET_PATH"]=""
SUMO__VARS["NET_PORT"]=""
SUMO__VARS["NET_LOGIN_REQUIRED"]="yes"
SUMO__VARS["BROWSER"]=""
SUMO__VARS["IMG_TYPE"]="img"
SUMO__VARS["CREATE_FILE"]=1
SUMO__VARS["FORMAT_DISK"]=false
SUMO__VARS["FLASH_DISK"]=""
SUMO__VARS["PART_DISK"]=""
SUMO__VARS["MOUNT_POINT"]=""
SUMO__VARS["MOUNT_POINT_SOURCE"]=""
SUMO__VARS["MOUNT_POINT_CREATED"]=1
SUMO__VARS["DO_UNMOUNT"]=1              # Default: no
SUMO__VARS["PASSPHRASE"]=""
SUMO__VARS["BLOCK_SIZE"]=1024
SUMO__VARS["FS_TYPE"]=ext4
SUMO__VARS["BLK_TYPE"]=""
SUMO__VARS["FS_LABEL"]=""
SUMO__VARS["MOUNTED"]=1                 # Default: no
SUMO__VARS["MOUNT_OPTIONS"]=""
SUMO__VARS["RUN_TESTS"]=1
SUMO__VARS["TEST_NAME"]=""
SUMO__VARS["BLKID_AVAIL"]=1
SUMO__VARS["LIST"]=1
SUMO__VARS["NO_HEADER"]=1
SUMO__VARS["SURROUNDING_FRAME"]=1
SUMO__VARS["DISPLAY_FORMAT"]="bolddisk"
SUMO__VARS["VERA_CREATION_OPTIONS"]="--protect-hidden=no --volume-type="normal" --encryption="Serpent-AES" --hash="SHA-512" -k \"\" --pim=0 --quick"
SUMO__VARS["SHOW_HISTORY"]=1            # Default: yes show
SUMO__VARS["SAVED_COLS_WIDTH"]=""
SUMO__VARS["SHOW_FILTER_IN_SRC_COL"]=true
SUMO__VARS["SAVED_LIST_LINE_WIDTH"]=""
SUMO__VARS["NB_SHOWN_DETAIL_LINES"]=0
SUMO__VARS["NB_SHOWN_HELP_LINES"]=0
SUMO__VARS["LIST_OPT_ALL"]=-1
SUMO__VARS["FIND_MNT_POLL_PID"]=0
SUMO__VARS["CACHE_LIST_DATA_DB"]=0

SUMO__VARS["nbMaxDetailsSectionLines"]=15
SUMO__VARS["minTermLineWidth"]=115 # It must be sufficient to display the largest prompt line
SUMO__VARS["CURRENT_TERM_HEIGHT"]=0
SUMO__VARS["CURRENT_TERM_WIDTH"]=0

SUMO__VARS["REPLACE_OLD_STRING"]=""
SUMO__VARS["REPLACE_NEW_STRING"]=""

#SUMO__VARS["LABEL_COL_INDEX"]=0

SUMO__VARS["OLD_LSBLK"]=""

SUMO__VARS["LSBLK_FIELDS"]="TYPE,PKNAME,LABEL,SIZE,FSTYPE,NAME,FSSIZE,FSUSED,FSAVAIL,RO,MOUNTPOINT,PARTUUID,PARTTYPE"
SUMO__VARS["FINDMNT_FIELDS"]="LABEL,SIZE,FSTYPE,SOURCE,SIZE,USED,AVAIL,OPTIONS,TARGET,PARTUUID,PARTUUID"

SUMO__VARS["OLD_LSBLK_FIELDS"]="TYPE,PKNAME,LABEL,SIZE,FSTYPE,NAME,RO,MOUNTPOINT,PARTUUID,PARTTYPE"
SUMO__VARS["OLD_FINDMNT_FIELDS"]="LABEL,SIZE,FSTYPE,SOURCE,OPTIONS,TARGET,PARTUUID,PARTUUID"



SUMO__VARS["LSBLK_TREE_CHARS"]='[└─├─|`-]'

:<<'EOF'
SUMO__VARS["AWK_LSBLK_TREE_FLATTENING_CMD"]='
/^\/[A-Za-z]/{d0=$1; mntp=""; if(NF > 2) { mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-";gsub(" ","§", mntp); printf("\"%s\" %s %s\n", mntp,$2,d0) };
/^'${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/{mntp="";d1=$1; if (NF > 2)  { mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); };  if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s\n", mntp,$2,d0, d1)  };
/^  '${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/{ mntp="";d2=$1;  if (NF > 2)  {  mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s %s\n", mntp,$2,d0,d1,d2) }
/^    '${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/{ mntp="";d3=$1;  if (NF > 2)  {  mntp=sprintf("%s",$3)  ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s %s %s\n", mntp,$2,d0,d1,d2,d3)}
END {
}
'
EOF

SUMO__VARS["AWK_LSBLK_TREE_FLATTENING_CMD"]='
match($0,/^\/[A-Za-z]/) { d0=$1; mntp=""; if(NF > 2) { mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-";gsub(" ","§", mntp); printf("\"%s\" %s %s\n", mntp,$2,d0) };
match($0,/^'${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/) {mntp=""; d1=substr($0,RLENGTH+1);d1=substr(d1,0,index(d1," ")-1);  if (NF > 2)  { mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); };  if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s\n", mntp,$2,d0, d1)  };
match($0,/^  '${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/) { mntp=""; d2=substr($0,RLENGTH+1);d2=substr(d2,0,index(d2," ")-1);  if (NF > 2)  {  mntp=sprintf("%s",$3) ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s %s\n", mntp,$2,d0,d1,d2) }
match($0,/^    '${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/) { mntp=""; d3=substr($0,RLENGTH+1);d3=substr(d3,0,index(d3," ")-1);  if (NF > 2)  {  mntp=sprintf("%s",$3)  ; for(i=4;i<=NF;i++) mntp=sprintf("%s %s",mntp,$i); }; if (length(mntp)==0) mntp="-"; gsub(" ","§", mntp); printf("\"%s\" %s %s %s %s %s\n", mntp,$2,d0,d1,d2,d3)}
END {
}
'
SUMO__VARS["AWK_LSBLK_TREE_FLATTENING_CMD_FOR_MOUNT_RESOLVE"]='
match($0,/^\/[A-Za-z]/) {d0=$1; print d0}
match($0,/^'${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/) { d1=substr($0,RLENGTH+1);d1=substr(d1,0,index(d1," ")-1); print d0, d1};
match($0,/^  '${SUMO__VARS["LSBLK_TREE_CHARS"]}'+/) {d2=substr($0,RLENGTH+1);d2=substr(d2,0,index(d2," ")-1); print d0, d1, d2}
'

# Readonly arrays
SUMO__VARS["SUMO__VERA_EXTENSIONS"]="vera hc"
SUMO__VARS["LUKS_EXTENSIONS"]="luks"
SUMO__VARS["VIRTDISK_EXTENSIONS"]="qcow2 vdi vmdk"
SUMO__VARS["SUMO__ALLSOFTDEVTYPES"]="
part
lvm
crypt
loop"

SUMO__VARS["SUMO__ALLFSTYPES"]="
linux_raid_member
ddf_raid_member
isw_raid_member
lsi_mega_raid_member
via_raid_member
silicon_medley_raid_member
nvidia_raid_member
promise_fasttrack_raid_member
hpt45x_raid_member
hpt37x_raid_member
adaptec_raid_member
jmicron_raid_member
bcache
ceph_bluestore
drbd
drbdmanage_control_volume
drbdproxy_datalog
LVM2_member
LVM1_member
DM_snapshot_cow
DM_verity_hash
DM_integrity
crypto_LUKS
VMFS_volume_member
ubi
vdo
stratis
BitLocker
vfat
swsuspend
swap
xfs
xfs_external_log
exfs
ext4dev
ext4
ext3
ext2
jbd
reiserfs
reiser4
jfs
udf
iso9660
zfs_member
hfsplus
hfs
ufs
hpfs
sysv
xenix
ntfs
ReFS
cramfs
romfs
minix
gfs
gfs2
ocfs
ocfs2
oracleasm
vxfs
squashfs
squashfs3
nss
btrfs
ubifs
bfs
VMFS
befs
nilfs2
exfat
f2fs
mpool
apfs
fuse.google-drive-ocamlfuse"




declare -A Sumo__PartitionTypes

Sumo__PartitionTypes["0"]="Empty"
Sumo__PartitionTypes["1"]="FAT12"
Sumo__PartitionTypes["2"]="XENIX root"
Sumo__PartitionTypes["3"]="XENIX usr"
Sumo__PartitionTypes["4"]="FAT16 <32M"
Sumo__PartitionTypes["5"]="Extended"
Sumo__PartitionTypes["6"]="FAT16"
Sumo__PartitionTypes["7"]="HPFS/NTFS/exFAT"
Sumo__PartitionTypes["8"]="AIX"
Sumo__PartitionTypes["9"]="AIX bootable"
Sumo__PartitionTypes["a"]="OS/2 Boot Manager"
Sumo__PartitionTypes["b"]="W95 FAT32"
Sumo__PartitionTypes["c"]="W95 FAT32 (LBA)"
Sumo__PartitionTypes["e"]="W95 FAT16 (LBA)"
Sumo__PartitionTypes["f"]="W95 Ext'd (LBA)"
Sumo__PartitionTypes["10"]="OPUS"
Sumo__PartitionTypes["11"]="Hidden FAT12"
Sumo__PartitionTypes["12"]="Compaq diagnostics"
Sumo__PartitionTypes["14"]="Hidden FAT16 <32M"
Sumo__PartitionTypes["16"]="Hidden FAT16"
Sumo__PartitionTypes["17"]="Hidden HPFS/NTFS"
Sumo__PartitionTypes["18"]="AST SmartSleep"
Sumo__PartitionTypes["1b"]="Hidden W95 FAT32"
Sumo__PartitionTypes["1c"]="Hidden W95 FAT32 (LBA)"
Sumo__PartitionTypes["1e"]="Hidden W95 FAT16 (LBA)"
Sumo__PartitionTypes["24"]="NEC DOS"
Sumo__PartitionTypes["27"]="Hidden NTFS WinRE"
Sumo__PartitionTypes["39"]="Plan 9"
Sumo__PartitionTypes["3c"]="PartitionMagic recovery"
Sumo__PartitionTypes["40"]="Venix 80286"
Sumo__PartitionTypes["41"]="PPC PReP Boot"
Sumo__PartitionTypes["42"]="SFS"
Sumo__PartitionTypes["4d"]="QNX4.x"
Sumo__PartitionTypes["4e"]="QNX4.x 2nd part"
Sumo__PartitionTypes["4f"]="QNX4.x 3rd part"
Sumo__PartitionTypes["50"]="OnTrack DM"
Sumo__PartitionTypes["51"]="OnTrack DM6 Aux1"
Sumo__PartitionTypes["52"]="CP/M"
Sumo__PartitionTypes["53"]="OnTrack DM6 Aux3"
Sumo__PartitionTypes["54"]="OnTrackDM6"
Sumo__PartitionTypes["55"]="EZ-Drive"
Sumo__PartitionTypes["56"]="Golden Bow"
Sumo__PartitionTypes["5c"]="Priam Edisk"
Sumo__PartitionTypes["61"]="SpeedStor"
Sumo__PartitionTypes["63"]="GNU HURD or SysV"
Sumo__PartitionTypes["64"]="Novell Netware 286"
Sumo__PartitionTypes["65"]="Novell Netware 386"
Sumo__PartitionTypes["70"]="DiskSecure Multi-Boot"
Sumo__PartitionTypes["75"]="PC/IX"
Sumo__PartitionTypes["80"]="Old Minix"
Sumo__PartitionTypes["81"]="Minix / old Linux"
Sumo__PartitionTypes["82"]="Linux swap / Solaris"
Sumo__PartitionTypes["83"]="Linux"
Sumo__PartitionTypes["84"]="OS/2 hidden or Intel hibernation"
Sumo__PartitionTypes["85"]="Linux extended"
Sumo__PartitionTypes["86"]="NTFS volume set"
Sumo__PartitionTypes["87"]="NTFS volume set"
Sumo__PartitionTypes["88"]="Linux plaintext"
Sumo__PartitionTypes["8e"]="Linux LVM"
Sumo__PartitionTypes["93"]="Amoeba"
Sumo__PartitionTypes["94"]="Amoeba BBT"
Sumo__PartitionTypes["9f"]="BSD/OS"
Sumo__PartitionTypes["a0"]="IBM Thinkpad hibernation"
Sumo__PartitionTypes["a5"]="FreeBSD"
Sumo__PartitionTypes["a6"]="OpenBSD"
Sumo__PartitionTypes["a7"]="NeXTSTEP"
Sumo__PartitionTypes["a8"]="Darwin UFS"
Sumo__PartitionTypes["a9"]="NetBSD"
Sumo__PartitionTypes["ab"]="Darwin boot"
Sumo__PartitionTypes["af"]="HFS / HFS+"
Sumo__PartitionTypes["b7"]="BSDI fs"
Sumo__PartitionTypes["b8"]="BSDI swap"
Sumo__PartitionTypes["bb"]="Boot Wizard hidden"
Sumo__PartitionTypes["bc"]="Acronis FAT32 LBA"
Sumo__PartitionTypes["be"]="Solaris boot"
Sumo__PartitionTypes["bf"]="Solaris"
Sumo__PartitionTypes["c1"]="DRDOS/sec (FAT-12)"
Sumo__PartitionTypes["c4"]="DRDOS/sec (FAT-16 < 32M)"
Sumo__PartitionTypes["c6"]="DRDOS/sec (FAT-16)"
Sumo__PartitionTypes["c7"]="Syrinx"
Sumo__PartitionTypes["da"]="Non-FS data"
Sumo__PartitionTypes["db"]="CP/M / CTOS / ..."
Sumo__PartitionTypes["de"]="Dell Utility"
Sumo__PartitionTypes["df"]="BootIt"
Sumo__PartitionTypes["e1"]="DOS access"
Sumo__PartitionTypes["e3"]="DOS R/O"
Sumo__PartitionTypes["e4"]="SpeedStor"
Sumo__PartitionTypes["ea"]="Rufus alignment"
Sumo__PartitionTypes["eb"]="BeOS fs"
Sumo__PartitionTypes["ee"]="GPT"
Sumo__PartitionTypes["ef"]="EFI (FAT-12/16/32)"
Sumo__PartitionTypes["f0"]="Linux/PA-RISC boot"
Sumo__PartitionTypes["f1"]="SpeedStor"
Sumo__PartitionTypes["f4"]="SpeedStor"
Sumo__PartitionTypes["f2"]="DOS secondary"
Sumo__PartitionTypes["fb"]="VMware VMFS"
Sumo__PartitionTypes["fc"]="VMware VMKCORE"
Sumo__PartitionTypes["fd"]="Linux raid autodetect"
Sumo__PartitionTypes["fe"]="LANstep"
Sumo__PartitionTypes["ff"]="BBT"


#    $(/sbin/blkid -k)) # --list-filesystems is not available everywhere  # spare a subshell by using the above builtin list
#fuse.gvfsd-fuse
SUMO__VARS["ALLIMAGETYPES"]="luks img qcow2 iso vmdk vdi vera hc"
SUMO__VARS["SUMO__ALLIMAGEBLKTYPES"]="crypto part qcow2 iso vmdk vbox"

# Maps
declare -A SUMO__CREATION_OPTIONS
declare -A SUMO__RECENT
declare -A SUMO__RECENT_IGNORED
declare -A SUMO__RECENT_KEY_INDIRECTION
declare -A SUMO__RECENT_IGNORE_SAVE
declare -A SUMO__NOT_MOUNTED
declare -A SUMO_DETAIL_HIDDEN_DATA_MAP
declare -A SUMO_DETAIL_RANKS_DATA_MAP

# Relate to displayed device list
SUMO__CURRENT_OPERATION="" # mount, unmount, list
SUMO__CURRENT_SELECT_INDEX=1
SUMO__CURRENT_LIST=""
SUMO__CURRENT_LIST_WITHOUT_RECENT=""
SUMO__CURRENT_LIST_SIZE=0
SUMO__CURRENT_LIST_SIZE_WITHOUT_RECENT=0
SUMO__CURRENT_RECENTLIST_SIZE=0 # Size of the visible recent list
SUMO__CURRENT_ROW=""
SUMO__LIST_CURRENT_HELP_CALLBACK=""
SUMO__LIST_LINE_WIDTH=0
SUMO__COLS_WIDTH=""
SUMO__PREV_LIST_LINE_WIDTH=0
SUMO__PREV_COLS_WIDTH=""
SUMO__LIST_LINE_WIDTH_WITHOUT_RECENT=0
SUMO__COLS_WIDTH_WITHOUT_RECENT=""

# This variable is used to keep track when there are multiple mountpoints for a single source
Sumo__targetsListOfMyselfOwner=()
Sumo__devicesOftargetsListOfMyselfOwner=()


SUMO__loadDepTimer=0
SUMO__loadModulesDepTimer=0
SUMO__perfTimer=0

source "${SUMO__VARS["SUMO__MY_DIR"]}/sumo__options.sh" 


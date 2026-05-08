#!/bin/bash
###############################################################################
# 
# HUMAN-READABLE "ASA AWK SCRIPT API"
# 
# Copyright (c) 2024-2026 Michel Mehl.
# All rights reserved. 
# Tous droits réservés (France).
# 
# License terms written down in file MIT_LICENSE.txt
# Les termes de la licence sont détaillés dans le fichier MIT_LICENSE.txt
# 
# Release file path: awk-api-dev.awk
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.0
# Source file last modification: 2026-05-08 02:52:14.801745397 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# A library of AWK functions for dealing with devices 
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

function initializePartitionTypesMap()
{
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
        Sumo__PartitionTypes["b"]="FAT32" # W95 FAT32
        Sumo__PartitionTypes["c"]="FAT32 (LBA)" # W95
        Sumo__PartitionTypes["e"]="FAT16 (LBA)" # W95
        Sumo__PartitionTypes["f"]="Ext'd (LBA)" # W95
        Sumo__PartitionTypes["10"]="OPUS"
        Sumo__PartitionTypes["11"]="Hidden FAT12"
        Sumo__PartitionTypes["12"]="Compaq diagnostics"
        Sumo__PartitionTypes["14"]="Hidden FAT16 <32M"
        Sumo__PartitionTypes["16"]="Hidden FAT16"
        Sumo__PartitionTypes["17"]="Hidden HPFS/NTFS"
        Sumo__PartitionTypes["18"]="AST SmartSleep"
        Sumo__PartitionTypes["1b"]="Hidden FAT32"  # W95
        Sumo__PartitionTypes["1c"]="Hidden FAT32 (LBA)" # W95
        Sumo__PartitionTypes["1e"]="Hidden FAT16 (LBA)" # W95
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

        Sumo__PartitionTypes["00000000-0000-0000-0000-000000000000"]="Unused entry"
        Sumo__PartitionTypes["024DEE41-33E7-11D3-9D69-0008C781F39F"]="MBR"
        Sumo__PartitionTypes["C12A7328-F81F-11D2-BA4B-00A0C93EC93B"]="EFI"
        Sumo__PartitionTypes["21686148-6449-6E6F-744E-656564454649"]="BIOS boot"
        Sumo__PartitionTypes["D3BFE2DE-3DAF-11DF-BA40-E3A556D89593"]="iFFS" # Intel Fast Flash  (for Intel Rapid Start technology)
        Sumo__PartitionTypes["F4019732-066E-4E12-8273-346C5641494F"]="Sony boot"
        Sumo__PartitionTypes["BFBFAFE7-A34F-448A-9A5B-6213EB736C22"]="Lenovo boot"
        # Windows
        Sumo__PartitionTypes["E3C9E316-0B5C-4DB8-817D-F92DF00215AE"]="Microsoft Reserved" #  MSR
        Sumo__PartitionTypes["EBD0A0A2-B9E5-4433-87C0-68B6B72699C7"]="Microsoft Basic data"
        Sumo__PartitionTypes["5808C8AA-7E8F-42E0-85D2-E1E90434CFB3"]="LDM metadata" # Logical Disk Manager 
        Sumo__PartitionTypes["AF9B60A0-1431-4F62-BC68-3311714A69AD"]="LDM data"
        Sumo__PartitionTypes["DE94BBA4-06D1-4D40-A16A-BFD50179D6AC"]="Microsoft Recovery"
        Sumo__PartitionTypes["37AFFC90-EF7D-4E96-91C3-2D7AE055B174"]="GPFS" #IBM General Parallel File System
        Sumo__PartitionTypes["E75CAF8F-F680-4CEE-AFA3-B001E56EFC2D"]="MS Storage Spaces"
        Sumo__PartitionTypes["558D43C5-A1AC-43C0-AAC8-D1472B2923D1"]="MS Storage Replica"
        Sumo__PartitionTypes["75894C1E-3AEB-11D3-B7C1-7B03A0000000"]="HP-UX Data"
        Sumo__PartitionTypes["E2A1E728-32E3-11D6-A682-7B03A0000000"]="HP-UX Service"
        Sumo__PartitionTypes["0FC63DAF-8483-4772-8E79-3D69D8477DE4"]="Linux"
        Sumo__PartitionTypes["A19D880F-05FC-4D3B-A006-743F0F84911E"]="Linux RAID"
        Sumo__PartitionTypes["6523F8AE-3EB1-4E2A-A05A-18B695AE656F"]="Linux root Alpha"
        Sumo__PartitionTypes["D27F46ED-2919-4CB8-BD25-9531F3C16534"]="Linux root ARC"
        Sumo__PartitionTypes["69DAD710-2CE4-4E3C-B16C-21A1D49ABED3"]="Linux root ARM 32‐bit"
        Sumo__PartitionTypes["B921B045-1DF0-41C3-AF44-4C6F280D3FAE"]="Linux root AArch64"
        Sumo__PartitionTypes["993D8D3D-F80E-4225-855A-9DAF8ED7EA97"]="Linux root IA-64"
        Sumo__PartitionTypes["77055800-792C-4F94-B39A-98C91B762BB6"]="Linux root LoongArch 64‐bit"
        Sumo__PartitionTypes["E9434544-6E2C-47CC-BAE2-12D6DEAFB44C"]="Linux root mips: 32‐bit MIPS BE" # BE big-endian
        Sumo__PartitionTypes["D113AF76-80EF-41B4-BDB6-0CFF4D3D4A25"]="Linux root mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["37C58C8A-D913-4156-A25F-48B1B64E07F0"]="Linux root mipsel: 32‐bit MIPS LE" # LE Little-endian
        Sumo__PartitionTypes["700BDA43-7A34-4507-B179-EEB93D7A7CA3"]="Linux root mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["1AACDB3B-5444-4138-BD9E-E5C2239B2346"]="Linux root PA-RISC"
        Sumo__PartitionTypes["1DE3F1EF-FA98-47B5-8DCD-4A860A654D78"]="Linux root 32‐bit PowerPC"
        Sumo__PartitionTypes["912ADE1D-A839-4913-8964-A10EEE08FBD2"]="Linux root 64‐bit PowerPC BE"
        Sumo__PartitionTypes["C31C45E6-3F39-412E-80FB-4809C4980599"]="Linux root 64‐bit PowerPC LE"
        Sumo__PartitionTypes["60D5A7FE-8E7D-435C-B714-3DD8162144E1"]="Linux root RISC-V 32‐bit"
        Sumo__PartitionTypes["72EC70A6-CF74-40E6-BD49-4BDA08E8F224"]="Linux root RISC-V 64‐bit"
        Sumo__PartitionTypes["08A7ACEA-624C-4A20-91E8-6E0FA67D23F9"]="Linux root s390"
        Sumo__PartitionTypes["5EEAD9A9-FE09-4A1E-A1D7-520D00531306"]="Linux root s390x"
        Sumo__PartitionTypes["C50CDD70-3862-4CC3-90E1-809A8C93EE2C"]="Linux root TILE-Gx"
        Sumo__PartitionTypes["44479540-F297-41B2-9AF7-D131D5F0458A"]="Linux root x86"
        Sumo__PartitionTypes["4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709"]="Linux root x86-64"
        Sumo__PartitionTypes["E18CF08C-33EC-4C0D-8246-C6C6FB3DA024"]="Linux user Alpha"
        Sumo__PartitionTypes["7978A683-6316-4922-BBEE-38BFF5A2FECC"]="Linux user ARC"
        Sumo__PartitionTypes["7D0359A3-02B3-4F0A-865C-654403E70625"]="Linux user ARM 32‐bit"
        Sumo__PartitionTypes["B0E01050-EE5F-4390-949A-9101B17104E9"]="Linux user AArch64"
        Sumo__PartitionTypes["4301D2A6-4E3B-4B2A-BB94-9E0B2C4225EA"]="Linux user IA-64"
        Sumo__PartitionTypes["E611C702-575C-4CBE-9A46-434FA0BF7E3F"]="Linux user LoongArch 64‐bit"
        Sumo__PartitionTypes["773B2ABC-2A99-4398-8BF5-03BAAC40D02B"]="Linux user mips: 32‐bit MIPS BE"
        Sumo__PartitionTypes["57E13958-7331-4365-8E6E-35EEEE17C61B"]="Linux user mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["0F4868E9-9952-4706-979F-3ED3A473E947"]="Linux user mipsel: 32‐bit MIPS LE"
        Sumo__PartitionTypes["C97C1F32-BA06-40B4-9F22-236061B08AA8"]="Linux user mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["DC4A4480-6917-4262-A4EC-DB9384949F25"]="Linux user PA-RISC"
        Sumo__PartitionTypes["7D14FEC5-CC71-415D-9D6C-06BF0B3C3EAF"]="Linux user 32‐bit PowerPC"
        Sumo__PartitionTypes["2C9739E2-F068-46B3-9FD0-01C5A9AFBCCA"]="Linux user 64‐bit PowerPC BE"
        Sumo__PartitionTypes["15BB03AF-77E7-4D4A-B12B-C0D084F7491C"]="Linux user 64‐bit PowerPC LE"
        Sumo__PartitionTypes["B933FB22-5C3F-4F91-AF90-E2BB0FA50702"]="Linux user RISC-V 32‐bit"
        Sumo__PartitionTypes["BEAEC34B-8442-439B-A40B-984381ED097D"]="Linux user RISC-V 64‐bit"
        Sumo__PartitionTypes["CD0F869B-D0FB-4CA0-B141-9EA87CC78D66"]="Linux user s390"
        Sumo__PartitionTypes["8A4F5770-50AA-4ED3-874A-99B710DB6FEA"]="Linux user s390x"
        Sumo__PartitionTypes["55497029-C7C1-44CC-AA39-815ED1558630"]="Linux user TILE-Gx"
        Sumo__PartitionTypes["75250D76-8CC6-458E-BD66-BD47CC81A812"]="Linux user x86"
        Sumo__PartitionTypes["8484680C-9521-48C6-9C11-B0720656F69E"]="Linux user x86-64"
        Sumo__PartitionTypes["FC56D9E9-E6E5-4C06-BE32-E74407CE09A5"]="Verity root Alpha"
        Sumo__PartitionTypes["24B2D975-0F97-4521-AFA1-CD531E421B8D"]="Verity root ARC"
        Sumo__PartitionTypes["7386CDF2-203C-47A9-A498-F2ECCE45A2D6"]="Verity root ARM 32‐bit"
        Sumo__PartitionTypes["DF3300CE-D69F-4C92-978C-9BFB0F38D820"]="Verity root AArch64"
        Sumo__PartitionTypes["86ED10D5-B607-45BB-8957-D350F23D0571"]="Verity root IA-64"
        Sumo__PartitionTypes["F3393B22-E9AF-4613-A948-9D3BFBD0C535"]="Verity root LoongArch 64‐bit"
        Sumo__PartitionTypes["7A430799-F711-4C7E-8E5B-1D685BD48607"]="Verity root mips: 32‐bit MIPS BE"
        Sumo__PartitionTypes["579536F8-6A33-4055-A95A-DF2D5E2C42A8"]="Verity root mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["D7D150D2-2A04-4A33-8F12-16651205FF7B"]="Verity root mipsel: 32‐bit MIPS LE"
        Sumo__PartitionTypes["16B417F8-3E06-4F57-8DD2-9B5232F41AA6"]="Verity root mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["D212A430-FBC5-49F9-A983-A7FEEF2B8D0E"]="Verity root PA-RISC"
        Sumo__PartitionTypes["906BD944-4589-4AAE-A4E4-DD983917446A"]="Verity root 64‐bit PowerPC LE"
        Sumo__PartitionTypes["9225A9A3-3C19-4D89-B4F6-EEFF88F17631"]="Verity root 64‐bit PowerPC BE"
        Sumo__PartitionTypes["98CFE649-1588-46DC-B2F0-ADD147424925"]="Verity root 32‐bit PowerPC"
        Sumo__PartitionTypes["AE0253BE-1167-4007-AC68-43926C14C5DE"]="Verity root RISC-V 32‐bit"
        Sumo__PartitionTypes["B6ED5582-440B-4209-B8DA-5FF7C419EA3D"]="Verity root RISC-V 64‐bit"
        Sumo__PartitionTypes["7AC63B47-B25C-463B-8DF8-B4A94E6C90E1"]="Verity root s390"
        Sumo__PartitionTypes["B325BFBE-C7BE-4AB8-8357-139E652D2F6B"]="Verity root s390x"
        Sumo__PartitionTypes["966061EC-28E4-4B2E-B4A5-1F0A825A1D84"]="Verity root TILE-Gx"
        Sumo__PartitionTypes["2C7357ED-EBD2-46D9-AEC1-23D437EC2BF5"]="Verity root x86-64"
        Sumo__PartitionTypes["D13C5D3B-B5D1-422A-B29F-9454FDC89D76"]="Verity root x86"
        Sumo__PartitionTypes["8CCE0D25-C0D0-4A44-BD87-46331BF1DF67"]="Verity user Alpha"
        Sumo__PartitionTypes["FCA0598C-D880-4591-8C16-4EDA05C7347C"]="Verity user ARC"
        Sumo__PartitionTypes["C215D751-7BCD-4649-BE90-6627490A4C05"]="Verity user ARM 32‐bit"
        Sumo__PartitionTypes["6E11A4E7-FBCA-4DED-B9E9-E1A512BB664E"]="Verity user AArch64"
        Sumo__PartitionTypes["6A491E03-3BE7-4545-8E38-83320E0EA880"]="Verity user IA-64"
        Sumo__PartitionTypes["F46B2C26-59AE-48F0-9106-C50ED47F673D"]="Verity user LoongArch 64‐bit"
        Sumo__PartitionTypes["6E5A1BC8-D223-49B7-BCA8-37A5FCCEB996"]="Verity user mips: 32‐bit MIPS BE"
        Sumo__PartitionTypes["81CF9D90-7458-4DF4-8DCF-C8A3A404F09B"]="Verity user mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["46B98D8D-B55C-4E8F-AAB3-37FCA7F80752"]="Verity user mipsel: 32‐bit MIPS LE"
        Sumo__PartitionTypes["3C3D61FE-B5F3-414D-BB71-8739A694A4EF"]="Verity user mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["5843D618-EC37-48D7-9F12-CEA8E08768B2"]="Verity user PA-RISC"
        Sumo__PartitionTypes["EE2B9983-21E8-4153-86D9-B6901A54D1CE"]="Verity user 64‐bit PowerPC LE"
        Sumo__PartitionTypes["BDB528A5-A259-475F-A87D-DA53FA736A07"]="Verity user 64‐bit PowerPC BE"
        Sumo__PartitionTypes["DF765D00-270E-49E5-BC75-F47BB2118B09"]="Verity user 32‐bit PowerPC"
        Sumo__PartitionTypes["CB1EE4E3-8CD0-4136-A0A4-AA61A32E8730"]="Verity user RISC-V 32‐bit"
        Sumo__PartitionTypes["8F1056BE-9B05-47C4-81D6-BE53128E5B54"]="Verity user RISC-V 64‐bit"
        Sumo__PartitionTypes["B663C618-E7BC-4D6D-90AA-11B756BB1797"]="Verity user s390"
        Sumo__PartitionTypes["31741CC4-1A2A-4111-A581-E00B447D2D06"]="Verity user s390x"
        Sumo__PartitionTypes["2FB4BF56-07FA-42DA-8132-6B139F2026AE"]="Verity user TILE-Gx"
        Sumo__PartitionTypes["77FF5F63-E7B6-4633-ACF4-1565B864C0E6"]="Verity user x86-64"
        Sumo__PartitionTypes["8F461B0D-14EE-4E81-9AA9-049B6FB97ABD"]="Verity user x86"
        Sumo__PartitionTypes["D46495B7-A053-414F-80F7-700C99921EF8"]="Verity root signature Alpha"
        Sumo__PartitionTypes["143A70BA-CBD3-4F06-919F-6C05683A78BC"]="Verity root signature ARC"
        Sumo__PartitionTypes["42B0455F-EB11-491D-98D3-56145BA9D037"]="Verity root signature ARM 32‐bit"
        Sumo__PartitionTypes["6DB69DE6-29F4-4758-A7A5-962190F00CE3"]="Verity root signature AArch64"
        Sumo__PartitionTypes["E98B36EE-32BA-4882-9B12-0CE14655F46A"]="Verity root signature IA-64"
        Sumo__PartitionTypes["5AFB67EB-ECC8-4F85-AE8E-AC1E7C50E7D0"]="Verity root signature LoongArch 64‐bit"
        Sumo__PartitionTypes["BBA210A2-9C5D-45EE-9E87-FF2CCBD002D0"]="Verity root signature mips: 32‐bit MIPS BE"
        Sumo__PartitionTypes["43CE94D4-0F3D-4999-8250-B9DEAFD98E6E"]="Verity root signature mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["C919CC1F-4456-4EFF-918C-F75E94525CA5"]="Verity root signature mipsel: 32‐bit MIPS LE"
        Sumo__PartitionTypes["904E58EF-5C65-4A31-9C57-6AF5FC7C5DE7"]="Verity root signature mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["15DE6170-65D3-431C-916E-B0DCD8393F25"]="Verity root signature PA-RISC"
        Sumo__PartitionTypes["D4A236E7-E873-4C07-BF1D-BF6CF7F1C3C6"]="Verity root signature 64‐bit PowerPC LE"
        Sumo__PartitionTypes["F5E2C20C-45B2-4FFA-BCE9-2A60737E1AAF"]="Verity root signature 64‐bit PowerPC BE"
        Sumo__PartitionTypes["1B31B5AA-ADD9-463A-B2ED-BD467FC857E7"]="Verity root signature 32‐bit PowerPC"
        Sumo__PartitionTypes["3A112A75-8729-4380-B4CF-764D79934448"]="Verity root signature RISC-V 32‐bit"
        Sumo__PartitionTypes["EFE0F087-EA8D-4469-821A-4C2A96A8386A"]="Verity root signature RISC-V 64‐bit"
        Sumo__PartitionTypes["3482388E-4254-435A-A241-766A065F9960"]="Verity root signature s390"
        Sumo__PartitionTypes["C80187A5-73A3-491A-901A-017C3FA953E9"]="Verity root signature s390x"
        Sumo__PartitionTypes["B3671439-97B0-4A53-90F7-2D5A8F3AD47B"]="Verity root signature TILE-Gx"
        Sumo__PartitionTypes["41092B05-9FC8-4523-994F-2DEF0408B176"]="Verity root signature x86-64"
        Sumo__PartitionTypes["5996FC05-109C-48DE-808B-23FA0830B676"]="Verity root signature x86"
        Sumo__PartitionTypes["5C6E1C76-076A-457A-A0FE-F3B4CD21CE6E"]="Verity user signature Alpha"
        Sumo__PartitionTypes["94F9A9A1-9971-427A-A400-50CB297F0F35"]="Verity user signature ARC"
        Sumo__PartitionTypes["D7FF812F-37D1-4902-A810-D76BA57B975A"]="Verity user signature ARM 32‐bit"
        Sumo__PartitionTypes["C23CE4FF-44BD-4B00-B2D4-B41B3419E02A"]="Verity user signature AArch64"
        Sumo__PartitionTypes["8DE58BC2-2A43-460D-B14E-A76E4A17B47F"]="Verity user signature IA-64"
        Sumo__PartitionTypes["B024F315-D330-444C-8461-44BBDE524E99"]="Verity user signature LoongArch 64‐bit"
        Sumo__PartitionTypes["97AE158D-F216-497B-8057-F7F905770F54"]="Verity user signature mips: 32‐bit MIPS BE"
        Sumo__PartitionTypes["05816CE2-DD40-4AC6-A61D-37D32DC1BA7D"]="Verity user signature mips64: 64‐bit MIPS BE"
        Sumo__PartitionTypes["3E23CA0B-A4BC-4B4E-8087-5AB6A26AA8A9"]="Verity user signature mipsel: 32‐bit MIPS LE"
        Sumo__PartitionTypes["F2C2C7EE-ADCC-4351-B5C6-EE9816B66E16"]="Verity user signature mips64el: 64‐bit MIPS LE"
        Sumo__PartitionTypes["450DD7D1-3224-45EC-9CF2-A43A346D71EE"]="Verity user signature PA-RISC"
        Sumo__PartitionTypes["C8BFBD1E-268E-4521-8BBA-BF314C399557"]="Verity user signature 64‐bit PowerPC LE"
        Sumo__PartitionTypes["0B888863-D7F8-4D9E-9766-239FCE4D58AF"]="Verity user signature 64‐bit PowerPC BE"
        Sumo__PartitionTypes["7007891D-D371-4A80-86A4-5CB875B9302E"]="Verity user signature 32‐bit PowerPC"
        Sumo__PartitionTypes["C3836A13-3137-45BA-B583-B16C50FE5EB4"]="Verity user signature RISC-V 32‐bit"
        Sumo__PartitionTypes["D2F9000A-7A18-453F-B5CD-4D32F77A7B32"]="Verity user signature RISC-V 64‐bit"
        Sumo__PartitionTypes["17440E4F-A8D0-467F-A46E-3912AE6EF2C5"]="Verity user signature s390"
        Sumo__PartitionTypes["3F324816-667B-46AE-86EE-9B0C0C6C11B4"]="Verity user signature s390x"
        Sumo__PartitionTypes["4EDE75E2-6CCC-4CC8-B9C7-70334B087510"]="Verity user signature TILE-Gx"
        Sumo__PartitionTypes["E7BB33FB-06CF-4E81-8273-E543B413E2E2"]="Verity user signature x86-64"
        Sumo__PartitionTypes["974A71C0-DE41-43C3-BE5D-5C5CCD1AD2C0"]="Verity user signature x86"
        Sumo__PartitionTypes["BC13C2FF-59E6-4262-A352-B275FD6F7172"]="XBOOTLDR" # Extended Boot Loader (XBOOTLDR) partition
        Sumo__PartitionTypes["0657FD6D-A4AB-43C4-84E5-0933C84B4F4F"]="Linux Swap"
        Sumo__PartitionTypes["E6D6D379-F507-44C2-A23C-238F2A3DF928"]="LVM" # Logical Volume Manager
        Sumo__PartitionTypes["933AC7E1-2EB4-4F13-B844-0E14E2AEF915"]="/home part"
        Sumo__PartitionTypes["3B8F8425-20E0-4F3B-907F-1A25A76F98E8"]="/srv part" #  (server data)
        Sumo__PartitionTypes["773F91EF-66D4-49B5-BD83-D683BF40AD16"]="Per‐user home"
        Sumo__PartitionTypes["7FFEC5C9-2D00-49B7-8941-3EA10A5586B7"]="Plain dm-crypt"
        Sumo__PartitionTypes["CA7D7CCB-63ED-4C53-861C-1742536059CC"]="LUKS"
        Sumo__PartitionTypes["8DA63339-0007-60C0-C436-083AC8230908"]="Reserved"
        Sumo__PartitionTypes["0FC63DAF-8483-4772-8E79-3D69D8477DE4"]="Linux" # GNU/Hurd filesystem data"
        Sumo__PartitionTypes["0657FD6D-A4AB-43C4-84E5-0933C84B4F4F"]="Linux Swap" # "GNU/Hurd Swap"
        Sumo__PartitionTypes["83BD6B9D-7F41-11DC-BE0B-001560B84F0F"]="FreeBSD Boot"
        Sumo__PartitionTypes["516E7CB4-6ECF-11D6-8FF8-00022D09712B"]="FreeBSD BSD disklabel"
        Sumo__PartitionTypes["516E7CB5-6ECF-11D6-8FF8-00022D09712B"]="FreeBSD Swap"
        Sumo__PartitionTypes["516E7CB6-6ECF-11D6-8FF8-00022D09712B"]="FreeBSD UFS" # Unix File System
        Sumo__PartitionTypes["516E7CB8-6ECF-11D6-8FF8-00022D09712B"]="FreeBSD Vinum" # Vinum volume manager partition
        Sumo__PartitionTypes["516E7CBA-6ECF-11D6-8FF8-00022D09712B"]="FreeBSD ZFS"
        Sumo__PartitionTypes["74BA7DD9-A689-11E1-BD04-00E081286ACF"]="FreeBSD nandfs"
        Sumo__PartitionTypes["48465300-0000-11AA-AA11-00306543ECAC"]="HFS+" # "Hierarchical File System Plus (HFS+) partition"
        Sumo__PartitionTypes["7C3457EF-0000-11AA-AA11-00306543ECAC"]="APFS" # Apple APFS container, APFS FileVault volume container 
        Sumo__PartitionTypes["55465300-0000-11AA-AA11-00306543ECAC"]="Apple UFS container"
        Sumo__PartitionTypes["6A898CC3-1DD2-11B2-99A6-080020736631"]="ZFS"
        Sumo__PartitionTypes["52414944-0000-11AA-AA11-00306543ECAC"]="Apple RAID"
        Sumo__PartitionTypes["52414944-5F4F-11AA-AA11-00306543ECAC"]="Apple RAID, offline"
        Sumo__PartitionTypes["426F6F74-0000-11AA-AA11-00306543ECAC"]="Apple Boot (Recovery HD)"
        Sumo__PartitionTypes["4C616265-6C00-11AA-AA11-00306543ECAC"]="Apple Label"
        Sumo__PartitionTypes["5265636F-7665-11AA-AA11-00306543ECAC"]="Apple TV Recovery" 
        Sumo__PartitionTypes["53746F72-6167-11AA-AA11-00306543ECAC"]="CoreStorage"   # Apple Core Storage ContainerHFS+ FileVault volume container 
        Sumo__PartitionTypes["69646961-6700-11AA-AA11-00306543ECAC"]="Apple APFS Preboot"
        Sumo__PartitionTypes["52637672-7900-11AA-AA11-00306543ECAC"]="Apple APFS Recovery"
        Sumo__PartitionTypes["6A82CB45-1DD2-11B2-99A6-080020736631"]="Solaris Boot"
        Sumo__PartitionTypes["6A85CF4D-1DD2-11B2-99A6-080020736631"]="Solaris Root"
        Sumo__PartitionTypes["6A87C46F-1DD2-11B2-99A6-080020736631"]="Solaris Swap"
        Sumo__PartitionTypes["6A8B642B-1DD2-11B2-99A6-080020736631"]="Solaris Backup"
        Sumo__PartitionTypes["6A898CC3-1DD2-11B2-99A6-080020736631"]="Solaris /usr"
        Sumo__PartitionTypes["6A8EF2E9-1DD2-11B2-99A6-080020736631"]="Solaris /var"
        Sumo__PartitionTypes["6A90BA39-1DD2-11B2-99A6-080020736631"]="Solaris /home"
        Sumo__PartitionTypes["6A9283A5-1DD2-11B2-99A6-080020736631"]="Solaris Alternate sector"
        Sumo__PartitionTypes["6A945A3B-1DD2-11B2-99A6-080020736631"]="Solaris Reserved"
        Sumo__PartitionTypes["6A9630D1-1DD2-11B2-99A6-080020736631"]="Solaris Reserved"
        Sumo__PartitionTypes["6A980767-1DD2-11B2-99A6-080020736631"]="Solaris Reserved"
        Sumo__PartitionTypes["6A96237F-1DD2-11B2-99A6-080020736631"]="Solaris Reserved"
        Sumo__PartitionTypes["6A8D2AC7-1DD2-11B2-99A6-080020736631"]="Solaris Reserved"
        Sumo__PartitionTypes["49F48D32-B10E-11DC-B99B-0019D1879648"]="NetBSD Swap"
        Sumo__PartitionTypes["49F48D5A-B10E-11DC-B99B-0019D1879648"]="NetBSD FFS"
        Sumo__PartitionTypes["49F48D82-B10E-11DC-B99B-0019D1879648"]="NetBSD LFS"
        Sumo__PartitionTypes["49F48DAA-B10E-11DC-B99B-0019D1879648"]="NetBSD RAID"
        Sumo__PartitionTypes["2DB519C4-B10F-11DC-B99B-0019D1879648"]="NetBSD Concatenated"
        Sumo__PartitionTypes["2DB519EC-B10F-11DC-B99B-0019D1879648"]="NetBSD Encrypted"
        Sumo__PartitionTypes["FE3A2A5D-4F32-41A7-B725-ACCC3285A309"]="ChromeOS kernel"
        Sumo__PartitionTypes["3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC"]="ChromeOS rootfs"
        Sumo__PartitionTypes["CAB6E88E-ABF3-4102-A07A-D4BB9BE3C1D3"]="ChromeOS firmware"
        Sumo__PartitionTypes["2E0A753D-9E48-43B0-8337-B15192CB1B5E"]="ChromeOS future use"
        Sumo__PartitionTypes["09845860-705F-4BB5-B16C-8A8A099CAF52"]="ChromeOS miniOS"
        Sumo__PartitionTypes["5DFBF5F4-2848-4BAC-AA5E-0D9A20B745A6"]="coreos-usr"
        Sumo__PartitionTypes["3884DD41-8582-4404-B9A8-E9B84F2DF50E"]="coreos-resize-rootfs"
        Sumo__PartitionTypes["C95DC21A-DF0E-4340-8D7B-26CBFA9A03E0"]="coreos-reserved"
        Sumo__PartitionTypes["BE9067B9-EA49-4F15-B4F6-F36F8C9E1818"]="coreos-root-raid"
        Sumo__PartitionTypes["42465331-3BA3-10F1-802A-4861696B7521"]="Haiku BFS"
        Sumo__PartitionTypes["85D5E45E-237C-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD Boot"
        Sumo__PartitionTypes["85D5E45A-237C-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD Data"
        Sumo__PartitionTypes["85D5E45B-237C-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD Swap"
        Sumo__PartitionTypes["0394EF8B-237E-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD Unix File System (UFS)"
        Sumo__PartitionTypes["85D5E45C-237C-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD Vinum volume manager"
        Sumo__PartitionTypes["85D5E45D-237C-11E1-B4B3-E89A8F7FC3A7"]="MidnightBSD ZFS"
        Sumo__PartitionTypes["45B0969E-9B03-4F30-B4C6-B4B80CEFF106"]="Journal"
        Sumo__PartitionTypes["45B0969E-9B03-4F30-B4C6-5EC00CEFF106"]="dm-crypt journal"
        Sumo__PartitionTypes["4FBD7E29-9D25-41B8-AFD0-062C0CEFF05D"]="OSD"
        Sumo__PartitionTypes["4FBD7E29-9D25-41B8-AFD0-5EC00CEFF05D"]="dm-crypt OSD"
        Sumo__PartitionTypes["89C57F98-2FE5-4DC0-89C1-F3AD0CEFF2BE"]="Disk in creation"
        Sumo__PartitionTypes["89C57F98-2FE5-4DC0-89C1-5EC00CEFF2BE"]="dm-crypt disk in creation"
        Sumo__PartitionTypes["CAFECAFE-9B03-4F30-B4C6-B4B80CEFF106"]="Block"
        Sumo__PartitionTypes["30CD0809-C2B2-499C-8879-2D6B78529876"]="Block DB"
        Sumo__PartitionTypes["5CE17FCE-4087-4169-B7FF-056CC58473F9"]="Block write-ahead log"
        Sumo__PartitionTypes["FB3AABF9-D25F-47CC-BF5E-721D1816496B"]="Lockbox for dm-crypt keys"
        Sumo__PartitionTypes["4FBD7E29-8AE0-4982-BF9D-5A8D867AF560"]="Multipath OSD"
        Sumo__PartitionTypes["45B0969E-8AE0-4982-BF9D-5A8D867AF560"]="Multipath journal"
        Sumo__PartitionTypes["CAFECAFE-8AE0-4982-BF9D-5A8D867AF560"]="Multipath block"
        Sumo__PartitionTypes["7F4A666A-16F3-47A2-8445-152EF4D03F6C"]="Multipath block"
        Sumo__PartitionTypes["EC6D6385-E346-45DC-BE91-DA2A7C8B3261"]="Multipath block DB"
        Sumo__PartitionTypes["01B41E1B-002A-453C-9F17-88793989FF8F"]="Multipath block write-ahead log"
        Sumo__PartitionTypes["CAFECAFE-9B03-4F30-B4C6-5EC00CEFF106"]="dm-crypt block"
        Sumo__PartitionTypes["93B0052D-02D9-4D8A-A43B-33A3EE4DFBC3"]="dm-crypt block DB"
        Sumo__PartitionTypes["306E8683-4FE2-4330-B7C0-00A917C16966"]="dm-crypt block write-ahead log"
        Sumo__PartitionTypes["45B0969E-9B03-4F30-B4C6-35865CEFF106"]="dm-crypt LUKS journal"
        Sumo__PartitionTypes["CAFECAFE-9B03-4F30-B4C6-35865CEFF106"]="dm-crypt LUKS block"
        Sumo__PartitionTypes["166418DA-C469-4022-ADF4-B30AFD37F176"]="dm-crypt LUKS block DB"
        Sumo__PartitionTypes["86A32090-3647-40B9-BBBD-38D8C573AA86"]="dm-crypt LUKS block write-ahead log"
        Sumo__PartitionTypes["4FBD7E29-9D25-41B8-AFD0-35865CEFF05D"]="dm-crypt LUKS OSD"
        Sumo__PartitionTypes["824CC7A0-36A8-11E3-890A-952519AD3F61"]="OpenBSD Data"
        Sumo__PartitionTypes["CEF5A9AD-73BC-4601-89F3-CDEEEEE321A1"]="Power-safe (QNX6)"
        Sumo__PartitionTypes["C91818F9-8025-47AF-89D2-F030D7000C2C"]="Plan 9"
        Sumo__PartitionTypes["9D275380-40AD-11DB-BF97-000C2911D1B8"]="vmkcore" # (coredump partition)
        Sumo__PartitionTypes["AA31E02A-400F-11DB-9590-000C2911D1B8"]="VMFS"  # VMFS filesystem partition
        Sumo__PartitionTypes["9198EFFC-31C0-11DB-8F78-000C2911D1B8"]="VMware Reserved"
        Sumo__PartitionTypes["2568845D-2332-4675-BC39-8FA5A4748D15"]="Android Bootloader"
        Sumo__PartitionTypes["114EAFFE-1552-4022-B26E-9B053604CF84"]="Android Bootloader2"
        Sumo__PartitionTypes["49A4D17F-93A3-45C1-A0DE-F50B2EBE2599"]="Android Boot"
        Sumo__PartitionTypes["4177C722-9E92-4AAB-8644-43502BFD5506"]="Android Recovery"
        Sumo__PartitionTypes["EF32A33B-A409-486C-9141-9FFB711F6266"]="Android Misc"
        Sumo__PartitionTypes["20AC26BE-20B7-11E3-84C5-6CFDB94711E9"]="Android Metadata"
        Sumo__PartitionTypes["38F428E6-D326-425D-9140-6E0EA133647C"]="Android System"
        Sumo__PartitionTypes["A893EF21-E428-470A-9E55-0668FD91A2D9"]="Android Cache"
        Sumo__PartitionTypes["DC76DDA9-5AC1-491C-AF42-A82591580C0D"]="Android Data"
        Sumo__PartitionTypes["EBC597D0-2053-4B15-8B64-E0AAC75F4DB1"]="Android Persistent"
        Sumo__PartitionTypes["C5A0AEEC-13EA-11E5-A1B1-001E67CA0C3C"]="Android Vendor"
        Sumo__PartitionTypes["BD59408B-4514-490D-BF12-9878D963F378"]="Android Config"
        Sumo__PartitionTypes["8F68CC74-C5E5-48DA-BE91-A0C8C15E9C80"]="Android Factory"
        Sumo__PartitionTypes["9FDAA6EF-4B3F-40D2-BA8D-BFF16BFB887B"]="Android Factory (alt)"
        Sumo__PartitionTypes["767941D0-2085-11E3-AD3B-6CFDB94711E9"]="Android Fastboot / Tertiary"
        Sumo__PartitionTypes["AC6D7924-EB71-4DF8-B48D-E267B27148FF"]="Android OEM"
        Sumo__PartitionTypes["19A710A2-B3CA-11E4-B026-10604B889DCF"]="Android6.0+ARM Meta"
        Sumo__PartitionTypes["193D1EA4-B3CA-11E4-B075-10604B889DCF"]="Android6.0+ARM EXT"
        Sumo__PartitionTypes["7412F7D5-A156-4B13-81DC-867174929325"]="ONIE Boot"
        Sumo__PartitionTypes["D4E6E2CD-4469-46F3-B5CB-1BFF57AFC149"]="ONIE Config"
        Sumo__PartitionTypes["9E1A2D38-C612-4316-AA26-8B49521E5A8B"]="PowerPC PReP boot"
        Sumo__PartitionTypes["BC13C2FF-59E6-4262-A352-B275FD6F7172"]="freedesktop.org shared bootloader cfg" # "freedesktop.org OSes (Linux, etc.) 	Shared boot loader configuration"
        Sumo__PartitionTypes["734E5AFE-F61A-11E6-BC64-92361F002671"]="Atari TOS Basic data" #  (GEM, BGM, F32)
        Sumo__PartitionTypes["35540011-B055-499F-842D-C69AECA357B7"]="Atari TOS Raw data/XHDI" # (RAW), XHDI
        Sumo__PartitionTypes["8C8F8EFF-AC95-4770-814A-21994F2DBC8F"]="VeraCrypt"
        Sumo__PartitionTypes["90B6FF38-B98F-4358-A21F-48F35B4A8AD3"]="OS/2 	ArcaOS Type 1"
        Sumo__PartitionTypes["7C5222BD-8F5D-4087-9C00-BF9843C7B58C"]="SPDK block device"
        Sumo__PartitionTypes["4778ED65-BF42-45FA-9C5B-287A1DC4AAB1"]="barebox-state"
        Sumo__PartitionTypes["3DE21764-95BD-54BD-A5C3-4ABE786F38A8"]="U-Boot"
        Sumo__PartitionTypes["B6FA30DA-92D2-4A9A-96F1-871EC6486200"]="SoftRAID_Status"
        Sumo__PartitionTypes["2E313465-19B9-463F-8126-8A7993773801"]="SoftRAID_Scratch"
        Sumo__PartitionTypes["FA709C7E-65B1-4593-BFD5-E71D61DE9B02"]="SoftRAID_Volume"
        Sumo__PartitionTypes["BBBA6DF5-F46F-4A89-8F59-8765B2727503"]="SoftRAID_Cache"
        Sumo__PartitionTypes["FE8A2634-5E2E-46BA-99E3-3A192091A350"]="Fuchsia Bootloader (slot A/B/R)"
        Sumo__PartitionTypes["D9FD4535-106C-4CEC-8D37-DFC020CA87CB"]="Fuchsia Durable mutable encrypted"
        Sumo__PartitionTypes["A409E16B-78AA-4ACC-995C-302352621A41"]="Fuchsia Durable mutable bootloader data (including A/B/R metadata)"
        Sumo__PartitionTypes["F95D940E-CABA-4578-9B93-BB6C90F29D3E"]="Fuchsia Factory System " # ro: read-only , Factory-provisioned read-only system data 
        Sumo__PartitionTypes["10B8DBAA-D2BF-42A9-98C6-A7C5DB3701E7"]="Fuchsia Factory Bootloader" # Factory-provisioned read-only bootloader data 
        Sumo__PartitionTypes["49FD7CB8-DF15-4E73-B9D9-992070127F0F"]="Fuchsia Volume Manager"
        Sumo__PartitionTypes["421A8BFC-85D9-4D85-ACDA-B64EEC0133E9"]="Fuchsia Verified boot metadata (slot A/B/R)"
        Sumo__PartitionTypes["9B37FFF6-2E58-466A-983A-F7926D0B04E0"]="Zircon boot image (slot A/B/R)"
        # SAME AS EFI !?!
        #Sumo__PartitionTypes["C12A7328-F81F-11D2-BA4B-00A0C93EC93B"]="fuchsia-esp"
        Sumo__PartitionTypes["606B000B-B7C7-4653-A7D5-B737332C899D"]="fuchsia-system"
        Sumo__PartitionTypes["08185F0C-892D-428A-A789-DBEEC8F55E6A"]="fuchsia-data"
        Sumo__PartitionTypes["48435546-4953-2041-494E-5354414C4C52"]="fuchsia-install"
        Sumo__PartitionTypes["2967380E-134C-4CBB-B6DA-17E7CE1CA45D"]="fuchsia-blob"
        Sumo__PartitionTypes["41D0E340-57E3-954E-8C1E-17ECAC44CFF5"]="fuchsia-fvm"
        Sumo__PartitionTypes["DE30CC86-1F4A-4A31-93C4-66F147D33E05"]="Zircon boot image (slot A)"
        Sumo__PartitionTypes["23CC04DF-C278-4CE7-8471-897D1A4BCDF7"]="Zircon boot image (slot B)"
        Sumo__PartitionTypes["A0E5CF57-2DEF-46BE-A80C-A2067C37CD49"]="Zircon boot image (slot R)"
        Sumo__PartitionTypes["4E5E989E-4C86-11E8-A15B-480FCF35F8E6"]="Fuchsia sys-config"
        Sumo__PartitionTypes["5A3A90BE-4C86-11E8-A15B-480FCF35F8E6"]="Fuchsia factory-config"
        Sumo__PartitionTypes["5ECE94FE-4C86-11E8-A15B-480FCF35F8E6"]="Fuchsia bootloader"
        Sumo__PartitionTypes["8B94D043-30BE-4871-9DFA-D69556E8C1F3"]="Fuchsia guid-test"
        Sumo__PartitionTypes["A13B4D9A-EC5F-11E8-97D8-6C3BE52705BF"]="Fuchsia Verified boot metadata (slot A)"
        Sumo__PartitionTypes["A288ABF2-EC5F-11E8-97D8-6C3BE52705BF"]="Fuchsia Verified boot metadata (slot B)"
        Sumo__PartitionTypes["6A2460C3-CD11-4E8B-80A8-12CCE268ED0A"]="Fuchsia Verified boot metadata (slot R)"
        Sumo__PartitionTypes["1D75395D-F2C6-476B-A8B7-45CC1C97B476"]="Fuchsia misc"
        Sumo__PartitionTypes["900B0FC5-90CD-4D4F-84F9-9F8ED579DB88"]="Fuchsia emmc-boot1"
        Sumo__PartitionTypes["B2B2E8D1-7C10-4EBC-A2D0-4614568260AD"]="Fuchsia emmc-boot2"
        Sumo__PartitionTypes["481B2A38-0561-420B-B72A-F1C4988EFC16"]="Minix"
        Sumo__PartitionTypes["3F82EEBC-87C9-4097-8165-89D6540557C0"]="Emu68/AmigaOS"
}

function getPartitionTypeName(partType)
{
        if (length(Sumo__PartitionTypes)==0)
                initializePartitionTypesMap()

        #log_err("parttype: " partType)
        if (length(partType)<=4)
        {
                partType=tolower(partType)
                if (startsWith(partType,"0x"))
                {
                       partType=trimAnySingleLeft(partType,"0");
                       partType=trimAnySingleLeft(partType,"x");
                }
        }
        else
        {
                partType=toupper(partType)
        }
        __partTypename=Sumo__PartitionTypes[partType]
        if (length(__partTypename)==0)
                __partTypename=partType
        return __partTypename
}

#
# ip address wrapper to retrieve device name, IP and MAC address of the local host
# @param iwconfig_info_range map for storing found properties
# @returns number of retrieved fields (4 normally)
#
function Net__ipaddr_getInterfaces(ipaddr_dev,ipaddr_ip,ipaddr_mac, currentIfaceIndex)
{
        currentIfaceIndex=0
        nbFound=0
        __cmd="ip a show up primary 2>/dev/null"
        #log_dbg("Net__ipaddr_getInterfaces " __cmd)

        while ( ( __cmd | getline result ) > 0 ) 
        {
                result=trim(result)
                #log_dbg("Net__ipaddr_getInterfaces line " result " " nbFound)                
                if (match(result,"^[0-9+]: [a-zA-Z0-9_]+"))
                {
                        currentIfaceIndex=currentIfaceIndex+1
                        devIndexColonIdx=index(result, ":")
                        ipaddr_dev[currentIfaceIndex]=trim(substr(result,devIndexColonIdx+2, RLENGTH-devIndexColonIdx-1))
                        #log_dbg("FOUND DEVICE : '" ipaddr_dev[currentIfaceIndex] "'")
                        nbFound=nbFound+1
                }                
                else if (startsWith(result,"inet "))
                {
                        split(result,inetAddrLineFields, " ")
                        ipaddr_ip[currentIfaceIndex]=inetAddrLineFields[2]
                        #log_dbg("FOUND IP : '" ipaddr_ip[currentIfaceIndex] "'")
                }
                else if (startsWith(result,"link/"))
                {
                        split(result,inetAddrLineFields, " ")
                        ipaddr_mac[currentIfaceIndex]=inetAddrLineFields[2]
                        #log_dbg("FOUND MAC : '" ipaddr_mac[currentIfaceIndex] "'")
                }
        }

        return nbFound
}



#
# iwconfig wrapper to retrieve specifically te following attributes to be  
# stored as props "speed" and "security" inside iwconfig_info_range
# "bssid" ("Access Point:")
# "link mode" : the IEEE normal
# "actual speed" ("Bit Rate")
# "link quality" ("Link Quality")
# 
# Note: iwconfig may be become obsolete, use iw dev <device> link
#
# @param idev system device path
# @param iwconfig_info_range map for storing found properties
# @returns number of retrieved fields (4 normally)
#
function Net__iwconfig_getConInfo(idev,iwconfig_info_range)
{
        nbInfos=5
        nbGotInfos=0

        __cmd="iwconfig " idev " 2>/dev/null"
        #log_dbg("WIFI Net__iwconfig_getConInfo " __cmd)

        while ( ( __cmd | getline result ) > 0 ) 
        {
                #log_dbg("WIFI Net__iwconfig_getConInfo line " result " " nbGotInfos " / " nbInfos)                
                if (startsWith(result,idev))
                {
                        split(trim(result),iwLineFields," ")
                        iwconfig_info_range["ieee"]=trim(iwLineFields[3])
                        nbGotInfos=nbGotInfos+1
                        idx=index(result,"ESSID:")
                        if (idx>0)
                        {
                                iwconfig_info_range["ESSID"]=trimAny(trim(substr(result,idx+6)),"\"")
                                nbGotInfos=nbGotInfos+1
                        }
                }
                else
                {
                        idx=index(result,"Access Point:")
                        if (idx>0)
                        {
                                iwconfig_info_range["BSSID"]=trim(substr(result,idx+13))
                                nbGotInfos=nbGotInfos+1
                        }
                        else
                        {
                                idx=index(result,"Link Quality=") # eg Link Quality=49/70
                                if (idx>0)
                                {
                                        iwLine=trim(substr(result,idx+13))
                                        split(iwLine,iwLineFields," ")
                                        iwconfig_info_range["link quality"]=trim(iwLineFields[1])
                                        nbGotInfos=nbGotInfos+1                                
                                }
                                else
                                {
                                        idx=index(result,"Bit Rate=") # eg Bit Rate=65 Mb/s
                                        if (idx>0)
                                        {
                                                iwLine=trim(substr(result,idx+9))
                                                split(iwLine,iwLineFields," ")
                                                iwconfig_info_range["bit rate"]=trim(iwLineFields[1] "§" iwLineFields[2])
                                                nbGotInfos=nbGotInfos+1                                        
                                        }
                                }
                        }
                }

                if (nbGotInfos == nbInfos)
                {
                        break
                }
        }
        return nbGotInfos
}

#
# nmcli wrapper to retrieve specifically the WIFI rate and security attributes and 
# stored as props "speed" and "security" inside nmcli_info_range.
#
# The following command is used (-g is the same as --terse --mode tabular --field...):
# nmcli -g rate,security device wifi list bssid <bssid>
# 
# Example of output:
#
# 260 Mbit/s:WPA1 WPA2
# Without -g:
# RATE        SECURITY  
# 260 Mbit/s  WPA1 WPA2 
#
# Alternatively, the following could have been used, filtering the 'in-use' field:
# Properties are retrieved with the following commands:
# nmcli --field in-use,bssid,rate,security device wifi list
#
# Example of output (alternative):
# IN-USE  BSSID              RATE        SECURITY    
# *       70:FC:8F:EE:7B:B8  260 Mbit/s  WPA1 WPA2   
#
#
#
function Net__nmcli_getWifiSecRate(bssid,nmcli_info_range)
{
        if (NMCLI_AVAIL==0)
                return 0

        __cmd="nmcli -g rate,security device wifi list bssid " bssid " 2>/dev/null"

        #log_dbg("WIFI Net__nmcli_getWifiSecRate " __cmd)

        if ( ( __cmd | getline result ) > 0 ) 
        {
                nbWifiSecRateFields=split(result,wifiSecRateFields,":")  
                if (nbWifiSecRateFields==2)
                {
                        nmcli_info_range["speed"]=wifiSecRateFields[1]
                        nmcli_info_range["security"]=wifiSecRateFields[2]
                }
        }
}

#
# nmcli wrapper for retrieving a range of the properties according to the entries of nmcli_info_range map
# having an initiale value, and populate it with the actual value found
#
# Properties are retrieved with nmcli device show <ifname> command
#
# @param system_device device path
# @param device_info_range an array of property names
# @return the number of found properties
#
function Net__nmcli_getConInfo(idev,nmcli_info_range)
{
        if (NMCLI_AVAIL==0)
                return 0

        __cmd="nmcli device show '" idev "' 2>/dev/null"


        nbInfos=length(nmcli_info_range)
        nbGotInfos=0

        #log_dbg("Net__nmcli_getConInfo " __cmd  " nbinfos:" nbInfos)

        while ( ( __cmd | getline result ) > 0 ) 
        {
                #log_dbg("nmcli " result )
                __devPropindex=index(result, ":")
                #log_dbg("nmcli " __devPropindex )
                if (__devPropindex)
                {
                        __devPropName=trim(substr(result,1,__devPropindex-1))
                        __devPropValue=trim(substr(result,__devPropindex+1))
                #log_dbg("nmcli  propname: '" __devPropName "' val:" __devPropValue )
                       if (length(nmcli_info_range[__devPropName])>0)
                        {
                #log_dbg("nmcli FOUND propname:" __devPropName " val:" __devPropValue )
                                nmcli_info_range[__devPropName]=__devPropValue
                                nbGotInfos=nbGotInfos+1
                        }

                        if (nbGotInfos == nbInfos)
                        {
                                break
                        }
                }                                
        } 
        close(__cmd);
        if (nbGotInfos > 0)
                NMCLI_AVAIL=1
        else
                NMCLI_AVAIL=0
        return nbGotInfos
}


#
# Gets the Ethernet interface information from a device interface name. It uses the underlying "ethtool" command
# 
# @param [1] ip address
# @param [2] eth properties : eth_props map contains the parsed data, with values set 
# for "supported link modes" , "link mode", "speed", "duplex", "link detected", "device",
# "host", "user", "share", "path" keys
# @returns 1 upon success, 0 if address was invalid
#
function Net__getEthInfo(idev,eth_props)
{
        __cmd="ethtool " idev " 2>/dev/null" # redirect to avoid Cannot get wake-on-lan settings: Operation not permitted
        __withinSupportedLinkModes=0
        __supportedLinkModes=""

        while ( ( __cmd | getline __result ) > 0 ) 
        {
                __line=trim(__result)
                __nbFields=split(__line,__fields,":")
                __keyField=""
                __dataField=""
                if (__nbFields >=2)
                {                        
                        __keyField=trim(__fields[1])
                        __dataField=trim(__fields[2])

                        __withinSupportedLinkModes = startsWith(__keyField,"Supported link modes")
                        if (! __withinSupportedLinkModes)
                        {
                                if (startsWith(__keyField,"Speed"))
                                        eth_props["speed"]=__dataField
                                else if (startsWith(__keyField,"Duplex"))
                                        eth_props["duplex"]=__dataField
                                else if (startsWith(__keyField,"Link detected"))
                                        eth_props["link_detected"]=__dataField
                        }
                } 
                else if (__nbFields >=1)
                {
                        __dataField=trim(__fields[1])
                }

                if (__withinSupportedLinkModes)
                        __supportedLinkModes=__supportedLinkModes" "__dataField
        }
        close(__cmd)
        eth_props["supported link modes"]=__supportedLinkModes
        eth_props["link mode"]=""

        # Search for the link mode id according to read speed and duplex
        __modespeed=eth_props["speed"]
        __modespeed=gensub(/^([0-9]+)(Mb\/s)/,"\\1", "g",__modespeed)

        nbLinkModes=split(__supportedLinkModes, __supportedLinkModesArray," ")
        for (i=1; i<= nbLinkModes;i++)
        {
                __linkMode=__supportedLinkModesArray[i] 
                __linkModeLow=tolower(__linkMode)
                __pat="^" __modespeed "base" "[^/]+" "/" tolower(eth_props["duplex"])
                # log_dbg("checking " __linkModeLow " against pattern " __pat)
                if (match(__linkModeLow,__pat)!=0)
                {
                        # log_dbg("FOUND!!")

                      __shortLinkMode=__linkMode
                      gsub("/Full$", "", __shortLinkMode)
                      gsub("/Half$", "", __shortLinkMode)
                      gsub("baseT", "BASE-T", __shortLinkMode)
                      eth_props["short link mode"]=toupper(__shortLinkMode)
                      gsub("baseT", "BASE-T", __linkMode)
                      gsub("/Full$", "-FD", __linkMode)
                      gsub("/Half$", "-HD", __linkMode)
                      eth_props["link mode"]=toupper(__linkMode)
                      break
                }
        }

        # log_dbg("mode speed:" __modespeed)

        return 1
}


#
# Gets the IP route information from an IP address hostname. It uses the underlying "ip route get" command
# 
# @param [1] ip address
# @param [2] array where to store the properties "device" giving the logical ethernet device name 
#            and "gateway"
#
# example of first line output for a host on the LAN: 
#   192.168.0.12 dev enx10653039a93c src 192.168.0.95 uid 1000 
# Note: command "ip route show to match 192.168.0.12" also is possible
#
# example of first line output for a host on the Internet: 
#   172.217.20.206 via 192.168.0.254 dev enx10653039a93c src 192.168.0.95 uid 1000 
#
function Net__getRouteInfos(ip, ip_props)
{
        __cmd="ip route get " ip 
        __res=exec(__cmd,1) # get first line only
        __nbFields=split(__res, __fields, " ")
        if (__nbFields >= 3)
        {
                if (tolower(__fields[2]) == "dev" )
                        ip_props["device"]=__fields[3]
                else
                if (tolower(__fields[4]) == "dev" )
                        ip_props["device"]=__fields[5]
                else
                        ip_props["device"]=""

                if (tolower(__fields[2]) == "via" )
                        ip_props["gateway"]=__fields[3]
        }
        else
        {
                ip_props["device"]=""
        }
}

#
# Gets the IP from a hostname. It uses the underlying "host" command
# 
# @param [1] hostname
# @returns the found IP, or empty string when name could be be resolved.
#
function Net__getHostIP(hostname)
{
        __cmd="host " hostname 
        __foundIP=""
        __hostRes=exec(__cmd)

        __nbRetHostLines=split(__hostRes,__hostLines,"\n")
        for (i=1;i <= __nbRetHostLines;i++)
        {
                __hostLine=__hostLines[i]
                if (index(__hostLine, " has address ")>0)
                {
                        __nbRetHostFields=split(__hostLine, __hostFields, " ")
                        if (__nbRetHostFields > 0)
                                __foundIP=trim(__hostFields[__nbRetHostFields])
                        else
                                __foundIP=""
                        return __foundIP
                }
        }
        return hostname
}

#
# Gets the MAC associated with a network system device
# 
# @param [1] device name
# @returns the found MAC
#
function Net__getMAC(idev)
{
        __cmd="ip -br link show " idev
        __foundMAC=""
        __IPRes=exec(__cmd,1)
        __nbRetIPFields=split(__IPRes, __IPFields, " ")
        if (__nbRetIPFields > 0)
                __foundMAC=trim(__IPFields[3])
        else
                __foundMAC=""
        return toupper(__foundMAC)
}


#
# Returns the connection type of an internet connection from an URL address.
# Currently, UNC address and SSH login address are supported.
# @param [1] URL
# @param [2] eth properties : con_props map contains detailed data for the respective keys:
# "device": IP system device name
# "host": host contained in URL
# "ip": IP of host defined in URL
# "user": username contained in URL
# "share": name of share (if UNC)
# "path": path (if SSH login)
# "link mode": ethernet link mode E.g. 1000BASE-T-FD
# "short link mode": a shorter ethernet link mode id with full/half duplex info E.g. 1000BASE-T
# @returns 1 upon success, 0 if address was invalid
#
# Connection types:
# 
#  ethernet     _/
#  wifi         _/
#  wimax
#  pppoe
#  gsm
#  cdma
#  infiniband
#  bluetooth
#  vlan
#  bond
#  bond-slave
#  team
#  team-slave
#  bridge
#  bridge-slave
#  vpn
#  olpc-mesh
#  adsl
#  tun
#  ip-tunnel
#  macvlan
#  vxlan
#  dummy
#
function Net__getConType(system_device,con_props)
{
        if (Net__isUNC(system_device))
        {
                con_props["host"]=""
                con_props["user"]=""
                Net__decodeUNC(system_device, con_props)
                # log_dbg("UNC address " devpath  " host: '" con_props["host"] "' share: '" con_props["share"] "'")
        } 
        else if (Net__isLogin(system_device))
        {
                con_props["host"]=""
                con_props["user"]=""
                Net__decodeLogin(system_device, con_props)
        }
        else if (Net__isHTTP(system_device))
        {
                con_props["host"]=system_device
                con_props["user"]=""
                con_props["port"]=""               
        }
        else if (Net__isCloudDevice(system_device))
        {
                con_props["host"]=""
                con_props["user"]=""
                Net__decodeHTTP(Net__getCloudURLFromDevice(system_device), con_props)                
        }
        else if (Net__isCurlFtpfs(system_device))
        {
                con_props["host"]=""
                con_props["user"]=""
                con_props["port"]=""
                Net__decodeCurlFtpfs(system_device, con_props)                
                #log_dbg("curtlftp: " system_device " '" con_props["host"] "' '" con_props["user"] "'")
        }        
        else if (Net__isNFS(system_device))
        {
                con_props["host"]=""
                con_props["path"]=""
                Net__decodeNFS(system_device, con_props)                
                #log_dbg("nfs: " system_device " '" con_props["host"] "' '" con_props["path"] "'")
        }        
        else
        {
                log_err("Invalid or unsupported URL address:'" system_device "'")
                return 0
        }

        if (Net__isIP(con_props["host"]))
        {
                con_props["ip"]=con_props["host"]
        }
        else
        {
                con_props["ip"]=Net__getHostIP(con_props["host"])
                #log_dbg(con_props["host"] " IS NOT IP. Resolved IP: '" con_props["ip"] "'")
        }

        # If IP couldn't be resolved by Net__getHostIP, then con_props["ip"] contains 
        # the hostname
        if (Net__isIP(con_props["ip"]))
        {
                # 'ip route get' requires a valid IP adress
                # Net__getRouteInfos also sets con_props["device"]

                Net__getRouteInfos(con_props["ip"], con_props)
                deviceName=con_props["device"]

                con_props["MAC"]=Net__getMAC(deviceName)
                con_props["link mode"]="n/a"
        }
        else
        {
                deviceName=""
                con_props["ip"]="n/a"
                con_props["MAC"]="n/a"
                con_props["link mode"]="n/a"
                split("", eth_props) # Reset array
                split("", etheth_props) # Reset array
        }

        if (length(deviceName)>0)
                if (length(cachedEthInfo[deviceName]["speed"]) > 0)
                {
                        #log_dbg("USING CACHE FOR " deviceName)
                        nbCachedProps=length(cachedEthInfo[deviceName]) 
                        for (ethkey in cachedEthInfo[deviceName]) 
                        {
                                #log_dbg("restoring cached eth prop '" ethkey "' with value '" cachedEthInfo[deviceName][ethkey]  "'")
                                con_props[ethkey]=cachedEthInfo[deviceName][ethkey]
                        }
                }
                else
                {                        
                        split("", eth_props) # Reset array
                        split("", etheth_props) # Reset array

                        #NMCLI_AVAIL=0                        

                        # without nmcli, security attributes and gateway missing
                        #log_dbg("Net__nmcli_getConInfo NOT OK")

                        split("",iwconfig_info_range)
                        if (Net__iwconfig_getConInfo(deviceName,iwconfig_info_range)==0)
                        {
                                # WIRED ETHERNET
                                Net__getEthInfo(deviceName,eth_props)
                        }
                        else
                        {
                                # WIFI
                                eth_props["link mode"]="WIFI§" iwconfig_info_range["ieee"]
                                eth_props["short link mode"]=eth_props["link mode"]
                                eth_props["actual speed"]=iwconfig_info_range["bit rate"]
                                eth_props["quality"]=iwconfig_info_range["link quality"]
                                eth_props["BSSID"]=iwconfig_info_range["BSSID"]
                                eth_props["ESSID"]=iwconfig_info_range["ESSID"]

                                # Get nominal "speed" and "security" attribute
                                Net__nmcli_getWifiSecRate(iwconfig_info_range["BSSID"], eth_props)

                                wifispeed=eth_props["speed"]
                                wifiversion=""
                                if (length(wifispeed) > 0)
                                {
                                        if (match(wifispeed,"^[0-9]+"))
                                        {
                                                wifispeed=int(substr(wifispeed,1,RLENGTH))
                                                #log_warn("WIFI SPEED : '" wifispeed "'")
                                                if (wifispeed > 23059) wifiversion="8"
                                                else if (wifispeed > 9608) wifiversion="7"
                                                else if (wifispeed > 6933) wifiversion="6"
                                                else if (wifispeed > 600) wifiversion="5"
                                                else if (wifispeed > 54) wifiversion="4"
                                                else if (wifispeed > 11) wifiversion="3"
                                                else if (wifispeed > 2) wifiversion="1"
                                                else wifiversion="0"
                                        }
                                        if (length(wifiversion)> 0)
                                        {
                                                eth_props["link mode"]="WIFI§" wifiversion
                                                eth_props["short link mode"]=eth_props["link mode"]
                                        }
                                }
                                else
                                {
                                        #eth_props["speed"]
                                }
                        }


                        for (eth_key in eth_props) cachedEthInfo[deviceName][eth_key]=eth_props[eth_key] # cache the eth props for the device
                        for (eth_key in eth_props) con_props[eth_key]=eth_props[eth_key] # transfer eth props to the con props
                }

        #log_dbg("Login address - host: '" con_props["ip"] "' user: '" con_props["user"] "' path: '" con_props["path"] "'" "' device: '" deviceName "'")
        #log_dbg("link mode: "  con_props["link mode"] " " con_props["short link mode"] " MAC:" con_props["MAC"]  " All modes supported:" con_props["supported link modes"])

        return 1
}

#
# Extracts hostname/ip and user from passed netlogin <user>@<host>[:path]
# examples of valid netlogin
# albert@192.168.0.40
# mikky@truesite.org:some/path
# 
# @param [1] Netlogin
# @param [2] login properties : login_props map contains the parsed data, with values set for "user", "host" and "path" keys 
# @returns 1 upon success, 0 if address was invalid
#
function Net__decodeLogin(login, login_props)
{
    if (! Net__isLogin(login))
        return 0

    nbloginfields=split(login, remainderfields,"@")
    # when no '@' found, result only in remainder and user is empty
    #log_dbg("nb fields for @:" nbloginfields)
    if (nbloginfields==1)
    {
      login_props["user"]=""
      remainder=remainderfields[1]
    }
    else if (nbloginfields==2)
    {
      login_props["user"]=remainderfields[1]
      remainder=remainderfields[2]
    }
   else
    {
        log_err("Inconsistent login address: " login)
        return 0
    }

    nbremainderfields=split (remainder, remainder2fields,":")
    # when no ':' found, results only in host and path is empty
    if (nbremainderfields==1)
         login_props["path"]=""
    else if (nbremainderfields>1)
    {
        login_props["host"]=remainder2fields[1]
        login_props["path"]=remainder2fields[2]
    } 
    else
    {
        log_err("Inconsistent login address: " login)
        return 0
    }

    return 1
}

#
# Extracts hostname/ip, share from passed UNC
# examples of valid netlogin
# //192.168.0.40/MyShareName
# @param [1] UNC
# @param [2] UNC properties : unc_props map contains the parsed data, with values set for "host" and "share" keys 
# @return 0 not a valid UNC address, 1 otherwise
#
function Net__decodeUNC(unc, unc_props)
{
    if (! Net__isUNC(unc) )
        return 0

    unc=trim(unc)
    // Remove everything before "//" first occurrence
    pat="^[^/]*(//)?"
    gsub(pat, "", unc)
    nbuncfields=split (unc, uncfields,"/")
    if (nbuncfields > 0)
        unc_props["host"]=uncfields[1]
    if (nbuncfields > 1)
        unc_props["share"]=uncfields[2]
    # when no '/' found, result only in host and share is empty
    return 1
}


# 
# Extracts only the host address from the HTTP URL
# @param [1] HTTP URL
# @param [2] URL properties : url_props map contains the parsed data, with values set for "host" and "port" keys 

function Net__decodeHTTP(url, url_props)
{
    if (! Net__isHTTP(url))
    {
        log_err("invalid HTTP URL' "$url "'.")
        return 0
    }

    url=trim(url)
    // Remove everything before "//" first occurrence
    pat="^[^/]+//"
    gsub(pat, "", url)
    nburlfields=split (url, urlfields,":")
    if (nburlfields > 0)
        url_props["host"]=urlfields[1]
    if (nburlfields > 1)
        {
            nbremainingfields=split (urlfields[2], remainingfields,"/")
            if (nbremainingfields > 0)
                url_props["port"]=remainingfields[1] # port may be empty
            # The remaining data i.e. path is not extracted at the moment
        }
    return 1
}

# curlftpfs#ftp://slash2438072@ftp.slashetc.fr
function Net__decodeCurlFtpfs(url, url_props)
{
    if (! Net__isCurlFtpfs(url))
    {
        log_err("invalid HTTP URL' "$url "'.")
        return 0
    }
    __urlOriginal=url
    url=trim(url)
    // Remove everything before "//" first occurrence
    pat="^[^/]+//"
    gsub(pat, "", url)
    nbloginfields=split(url, fields,"@")
    # when no '@' found, result only in remainder and user is empty
    #log_dbg("nb fields for @:" nbloginfields)
    if (nbloginfields==1)
    {
      con_props["user"]=""
      remainder=fields[1]
    }
    else if (nbloginfields==2)
    {
      con_props["user"]=fields[1]
      remainder=fields[2]
    }
   else
    {
        log_err("Inconsistent ftp address: " __urlOriginal)
        return 0
    }


    nbsubfields=split (remainder, subfields,":")
    # when no ':' found, results only in host and port is empty
    if (nbsubfields==1)
    {
      con_props["host"]=trimAnyRight(subfields[1],"/")
    }
    else if (nbsubfields>1)
    {
      con_props["host"]=trimAnyRight(subfields[1],"/")
      con_props["port"]=subfields[2]
    } 
    else
    {
      log_err("Inconsistent ftp address: " __urlOriginal)
      return 0
    }

    return 1

}


# Extracts hostname and share from the passed URL
# host:share_path
# @param [1] NFS URL
# @param [2] out resulting hostname (or IP)
# @param [6] out resulting share path
function Net__decodeNFS(url, url_props) 
{
    if (! Net__isNFS(url))
    {
        log_warn("invalid NFS URL '" url "'.")
        return 0
    }
    url=trim(url)
    url=trimAnyRight(url,"/")

    _semiColonIndex=index(url,":");
    if (_semiColonIndex > 0)
    {
        url_props["host"]=substr(url,0,_semiColonIndex-1);
        url_props["path"]=substr(url,_semiColonIndex+1);
    }
    else
    {
        url_props["host"]=url;
        url_props["path"]="";
    }
   
    return 1
}

function Net__getCloudURLFromDevice(s)
{
   if (tolower(s)=="google-drive-ocamlfuse") return "https://drive.google.com"
   return ""
}

# 
# Retrieves the USB version according to the vendor id and model id returned by 
# udevadm.
# The USB version is deduced from the usb speed extracted with lsusb. When finding
# a line starting with "ID <vendorid>:<modelid> , it looks at the last field of the previous line:
#
# Sample lsbusb output:
#            |__ Port 1: Dev 10, If 0, Class=Mass Storage, Driver=usb-storage, 480M
#                ID 0781:5583 SanDisk Corp. Ultra Fit
#
# 12M = 12MBit/s = USB1
# 480M = 480MBit/s = USB2
# 5000M = 5000MBit/s = USB3.0 aka USB3.1 gen. 1
# 10000M = 10000MBit/s = USB3.1 gen. 2
#



function getUSBVersion(system_device, vendor_id, model_id)
{
        __cmd="lsusb -v -d " vendor_id ":" model_id  " 2>/dev/null"
        retUsbVersion="?"

        #log_dbg("getUSBVersion for " vendor_id ":" model_id " cmd:" __cmd)
        while ( ( __cmd | getline result ) > 0 ) 
        {
                trimmedResult=trim(result)
                lsbusbLines[lineCounter]=trimmedResult
                lineCounter=lineCounter+1

                if (startsWith(trimmedResult, "bcdUSB"))
                {
                        nbUsbData=split(trimmedResult,bcdUSBFieldData," ")
                        #log_dbg("getUSBVersion line '" trimmedResult "' nb data : " nbUsbData)
                        if (nbUsbData > 0)
                        {
                                #retUsbVersion=squeezeEndChar( trim(bcdUSBFieldData[2]) , "0")
                                retUsbVersion=trimAnyRight( trim(bcdUSBFieldData[2]) , "0")
                                retUsbVersion=trimAnyRight(retUsbVersion, ".")
                                #log_dbg("FOUND USB VERSION :'" retUsbVersion "'")
                                break
                        }
                }
        } 
        close(__cmd);
        return retUsbVersion
}

#
# Retrieves one of the property provided udevadm according to the property name
# device_info
# @param system_device device path
# @param device_info property name
# @return the found device info or '-' if nothing could be found
#
function getDeviceInfo(system_device, device_info)
{
        __cmd="udevadm info '"system_device"' 2>/dev/null"
        while ( ( __cmd | getline result ) > 0 ) 
        {
                split(result,array,"="); 
                if (array[1] == device_info)
                {
                        close(__cmd);
                        return array[2]
                }
        } 
        close(__cmd);
        return "-"
}

#
# Retrieves a range of the properties by entries of device_info_range map
# having an initiale value, and populate it with the actual value found
#
# Using this function as alternative to 'getDeviceInfo' enables to save
# system calls when multiple properties have to be read.
#
# @param system_device device path
# @param device_info_range an array of property names
# @return the number of found properties
#
function getDeviceInfoRange(system_device, device_info_range)
{
        __cmd="udevadm info '"system_device"' 2>/dev/null"

        nbInfos=length(device_info_range)
        nbGotInfos=0
        
        while ( ( __cmd | getline result ) > 0 ) 
        {
                split(result,dev_info_array,"="); 
                # log_dbg("has read '"dev_info_array[1] "'  its len:" length(device_info_range[dev_info_array[1]]))
                if (length(device_info_range[dev_info_array[1]])>0)
                {
                        #returnedDeviceRangeInfos=returnedDeviceRangeInfos","dev_info_array[2]
                        device_info_range[dev_info_array[1]]=trim(dev_info_array[2])
                        nbGotInfos=nbGotInfos+1
                }

                if (nbGotInfos == nbInfos)
                {
                        break
                }
        } 
        close(__cmd);
        return nbGotInfos
}


#
# Determines whether a device is bootable based on the infos retrieved from 'parted' tool
# @param system_device device path
# @return a boolean , i.e. 1 if bootable, 0 otherwise
#
function isBootable(system_device) 
{
        __cmd="sudo parted "system_device" print 2>/dev/null"
        dflagseen=0
        while ( ( __cmd | getline partline ) > 0 ) 
        {
                partline=trim(squeeze(partline))
                split(partline,partFields," ");  
                if (dflagseen) 
                {  
                        if (partFields[1]=="1") 
                        { 
                                close(__cmd)                                
                                if (match(partline,"boot")!=0)                                                
                                        return 1
                                else
                                        return 0
                        }  
                }
                else if ((partFields[1]=="Disk") && (partFields[2]=="Flags:")) 
                {
                        dflagseen=1; 
                }
        }
        close(__cmd)
        return 0
}

#
# Read list of all mounted devices from 'mount' tool
# @param system_device device path
# @output global variables mountList (full list) and mountListItems
# containing each lines
#
function readFullMountList(system_device)
{
        mountList=exec("mount|sort")
#print mountList|"cat 1>&2"
        split(mountList,mountListItems,"\n")
}

#
# Retrieves from 'findmnt' tool the mount point corresponding to a source device 
# @param system_device device path
# @return mount point 
#
function findMountPoint(system_device)
{
        return exec("findmnt -n --source "system_device" -o TARGET")
}

#
# Retrieves from 'findmnt' tool the mount options corresponding to a source device 
# @param system_device device path
# @return mount options
#
function findMountPointOptions(system_device)
{
        return exec("findmnt -n --source "system_device" -o options")
}        


function isVeraAvailable() 
{
        if (g_isVeraAvailableDone) return g_isVeraAvailable

        isVeraAvailableTestRes=exec("which veracrypt || echo 'no'")
        if (isVeraAvailableTestRes=="no")
        {
                g_isVeraAvailable=0
                g_isVeraAvailableDone=1
                return 0
        }
        else
        {
                g_isVeraAvailable=1
                g_isVeraAvailableDone=1
                return 1
        }
}


function Vera__getAllDeviceMapper()
{
   if (!isVeraAvailable()) return ""

   veraitem= exec("veracrypt -l 2>/dev/null | awk \"{ \
   head = \\\"\\\" ; \
   while ( match(\\$0,\\\"'[^']*'\\\") ) { \
      head = head substr(\\$0,1,RSTART-1) gensub(/ /,\\\"§§\\\",\\\"g\\\",substr(\\$0,RSTART,RLENGTH)) ;\
      \\$0 = substr(\\$0,RSTART+RLENGTH) \
   } ; \
   print head \\$0 \
   }\" | awk -F' ' '{ print $3 }' \
   ")

#print veraitem|"cat 1>&2"
#  print "Vera find label for mount ",vera_mntp, "found:", veraitem|"cat 1>&2"

   return veraitem        
}

#
# Retrieves from 'veracrypt' tool the assigned VERA volume slot according to the 
# the passed mount point.
# @param vera_mntp VERA mount point (path)
# @return VERA slot 
#
function Vera__findLabelFromMountPoint(vera_mntp)
{
        #return exec("veracrypt -l|grep '"vera_mntp"'|cut -d':' -f1")
        #veraitem= exec("veracrypt -l|awk -F' ' -v mntp='"vera_mntp"' '{ if ($4==mntp) { print $1 ; exit 0} }'")

   if (!isVeraAvailable()) return ""

veraitem= exec("veracrypt -l| awk \"{ \
   head = \\\"\\\" ; \
   while ( match(\\$0,\\\"'[^']*'\\\") ) { \
      head = head substr(\\$0,1,RSTART-1) gensub(/ /,\\\"§§\\\",\\\"g\\\",substr(\\$0,RSTART,RLENGTH)) ;\
      \\$0 = substr(\\$0,RSTART+RLENGTH) \
   } ; \
   print head \\$0 \
   }\" | awk -F' ' -v mntp='"vera_mntp"' '{ if ($4==mntp) { print $1 ; exit 0} }' \
   ")

#print veraitem|"cat 1>&2"
#  print "Vera find label for mount ",vera_mntp, "found:", veraitem|"cat 1>&2"

   return veraitem
}

#
# Retrieves the boot type from 'gdisk' tool
# @param devpath device path
# @return boot type, GPT or MDR or APM or BSD
#
function getBootType(devpath)
{
        boottype=""
        # on old or damaged systems, it may ask for either using current GPT (option 1) or create a blank one (option2)
        #   
        cmd="sudo gdisk -l '"devpath"' 2>/dev/null <<EOM\nqEOM" 
        
        isGPT=0
        isGPTDamaged=1
        isMBRDamaged=1
        isMBR=0
        isAPM=0
        isBSD=0
        nbBoot=0
        while ( ( cmd | getline gdiskLine ) > 0 )  
        {
                #log_dbg("getBootType :" devpath " : " gdiskLine)
                #if (length(gdiskLine) > 0) 
                if (match(gdiskLine,"GPT: damaged")!=0) { isGPTDamaged=0; }
                else if (match(gdiskLine,"MBR: damaged")!=0) { isMBRDamaged=0; }
                else if (match(gdiskLine,"GPT: not present")!=0) isGPT=1;
                else if (match(gdiskLine,"MBR: not present")!=0) isMBR=1;
                else if (match(gdiskLine,"APM: not present")!=0) isAPM=1;
                else if (match(gdiskLine,"BSD: not present")!=0) isBSD=1;
        }
        close(cmd);  
        if (isGPTDamaged == 0) 
        { 
               boottype="GPT damaged";  nbBoot=nbBoot+1;
        }
        else if (isMBRDamaged == 0) 
        { 
                if (isBootable(devpath)) { boottype="MBR damaged"; nbBoot=nbBoot+1;}
        }
        else if (isGPT == 0) 
        { 
                if (isBootable(devpath)) { boottype="GPT"; nbBoot=nbBoot+1;}
        }
        else
        {                        
                if (isMDR == 0) {  if (isBootable(devpath)) { if (nbBoot >0 ) boottype=boottype "," ; boottype=boottype "MDR"; nbBoot=nbBoot+1; } }                       
                if (isAPM == 0) {  if (isBootable(devpath)) { if (nbBoot >0 ) boottype=boottype "," ; boottype=boottype "APM"; nbBoot=nbBoot+1; } }
                if (isBSD == 0) {  if (isBootable(devpath)) { if (nbBoot >0 ) boottype=boottype "," ; boottype=boottype "BSD"; nbBoot=nbBoot+1; } }
        }
        #log_dbg("getBootType  RES:" boottype ", nbBoot: " nbBoot)
        if (nbBoot==0) boottype="-";
        return boottype
}

function getPartitionType(system_device)
{
    __devicePath=""
    __deviceNo=""
    __partType=""
    __pat="[0-9]+$"
    if (match(system_device,__pat))
    {
        __devicePath=substr(system_device,0,RSTART-1)
        __deviceNo=substr(system_device,RSTART)
         #printf("%s %s", device, deviceNo)
        __partType=exec("sudo sfdisk --part-type " __devicePath " " __deviceNo " 2>/dev/null")
        # Shorten FAT partition type name
        __partType=trim(__partType)
    }
    else
    {
        log_warn("Failed to extract device path and partition No from '" system_device "'")
    }
    return __partType
}

function getDeviceAvailableSpace(system_device)
{
        dfres=exec("df -h " system_device " --output=source,avail 2>/dev/null", "", "yes")
        if (dfres !="")
        {
                nbDfFields=split(dfres,dfResFieldValues," ")
                if (nbDfFields == 2)
                {
                        if (trim(dfResFieldValues[1])!="udev")
                                return  trim(dfResFieldValues[2])
                }
        }
        return "-"
}

function getAdbSizeAndAvailableSpace(system_device)
{
        dfres=exec("timeout -s SIGKILL 3 adb shell df -h " system_device " 2>/dev/null", "", "yes")
        if (dfres !="")
        {
                nbDfFields=split(dfres,dfResFieldValues," ")
                if (nbDfFields == 6)
                {
                        return  trim(dfResFieldValues[2]) "," trim(dfResFieldValues[4])
                }
        }
        return "-"
}


function getAdbVersion()
{
        dfres=exec("timeout -s SIGKILL 2 adb shell getprop ro.build.version.release 2>/dev/null", "", "yes")
        if (dfres !="")
        {
                return dfres
        }
        return "-"
}

function getAdbSdkVersion()
{
        dfres=exec("timeout -s SIGKILL 2 adb shell getprop ro.build.version.sdk 2>/dev/null", "", "yes")
        if (dfres !="")
        {
                return dfres
        }
        return "-"
}

function getAdbDeviceName()
{
        adbRes=exec("timeout -s SIGKILL 2 adb devices 2>/dev/null", "", "") # get last line
        adbRes=squeeze(trim(adbRes))
#log_warn("adbRes: " adbRes)
        if (adbRes !="")
        {
                nbAdbResLines=split(adbRes,adbResLines,"\n")
                for (i=1; i<=nbAdbResLines;i++)
                {
                        adbResLine=adbResLines[i]
#log_warn("adbResLine: " adbResLine)

                        nbAdbResFields=split(adbResLine,adbResFieldValues," ")
                        if (nbAdbResFields >= 2)
                        {
                                adbResDeviceName=adbResFieldValues[1]
                                adbResDeviceStatus=adbResFieldValues[2]
#log_warn("adbResDeviceName: " adbResDeviceName "adbResDeviceStatus: " adbResDeviceStatus)
                                if (! startsWith(tolower(adbResDeviceName),"list"))
                                {
                                        if (tolower(adbResDeviceStatus)=="device")
                                                return trim(adbResDeviceName)
                                }
                        }
                }
        }
        return "-"
}

function isDockerOverlayMount(__in_lowerDir, __in_upperDir, __in_mountedFolder)
{
        #log_dbg(__in_lowerDir " " __in_upperDir " " __in_mountedFolder)
        __DOCKER_DIR__="/var/lib/docker"
        return (startsWith(__in_lowerDir,__DOCKER_DIR__) &&
                startsWith(__in_upperDir,__DOCKER_DIR__) &&
                startsWith(__in_mountedFolder,__DOCKER_DIR__));
}

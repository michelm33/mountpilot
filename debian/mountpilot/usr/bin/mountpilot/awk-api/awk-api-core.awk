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
# Release file path: awk-api-core.awk
# Release file date: 2026-05-08 15:10
# Software product version: 2.0.0
# Source file last modification: 2026-03-07 10:23:57.344744595 +0000
#
# This header was generated. Do not modify.
#
# ------------------------------------------------------------------------------
#
# A set of basic AWK functions.
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
@load "filefuncs"
function fileexist(file){
  return stat(file, null) == 0;
  #log_err("fileexist ret:" ret)
}

function log_err(msg) { print "[error]:",msg|"cat 1>&2"; }
function log_warn(msg) { print "[warning]:",msg|"cat 1>&2"}
function log_dbg(msg) { if (length(LOG_DEBUG)>0) print msg|"cat 1>&2"}
function startsWith(s,starts) { pat="^"starts; if (length(starts)==0) return 0 ; else return (match(s,pat)!=0); }
function squeeze(s) { gsub(/[ \t]+/," ", s); return s; }
function squeezeEndChar(s,c) {  pat="[" c "]+$" ; gsub(pat,c, s); return s; }
function trimAnyLeft(s,c) { pat="^[" c "]+"; gsub(pat, "", s); return s; }

function trimAnySingleLeft(s,c) { pat="^" c "+"; gsub(pat, "", s); return s; }

function trimAnyRight(s,c) { pat="[" c "]+$" ; gsub(pat, "", s); return s; }
function trimLeft(s) { gsub(/^[ \t\r\n]+/, "", s); return s; }
function trimRight(s) { gsub(/[ \t\r\n]+$/, "", s); return s; }
function trim(s) { return trimRight(trimLeft(s));}
function trimAny(s,c) { return trimAnyRight(trimAnyLeft(s,c),c);}
function basename(s) {  if (match(s,"/[^/]+$")) { return substr(s,RSTART+1,RLENGTH) } else { return s } }
function corename(s) {  s=basename(s) ; if (match(s,"[^.]+$")) { return substr(s,0,RSTART-2) } else { return s } }
function File__extension(s) {  if (match(s,"[^.]+$")) { return substr(s,RSTART,RLENGTH) } else { return s } }
function truncateMid3Dots(s, maxlen)
{
        sep="..."
        len=length(s)
        lensep=length(sep)
        if ((len > (3*lensep)) && (len > maxlen))
        {
                leftSideLen=int((maxlen-lensep)/2)
                rightSideLen=leftSideLen
                if (((2*leftSideLen)+lensep) < len)
                {
                        rightSideLen=rightSideLen+1
                }
#        log_dbg("trunc " s " len:" len " left len " leftSideLen " right len " rightSideLen)

                return substr(s,1,leftSideLen) sep substr(s,len-rightSideLen+1,rightSideLen)
        }
        else
        {
                return s
        }
}

function escapeSpaces(s,c)
{ 
        __ts=trimRight(trimLeft(s));
        gsub(/[ \t]+/,c, __ts); 
        return __ts;
}

function exec(command, exec_head_only, exec_tail_only) 
{
        __result=""
        __line=""
        __firstLine=1
        while ( ( command | getline __line ) > 0 ) 
        {
                if (__firstLine)
                {
                        __result=__line
                        __firstLine=0
                        if (length(exec_head_only)>0)
                                break
                }
                else
                {
                        __result=__result"\n"__line
                }
        }        
        close(command);  
        if (length(exec_tail_only)>0)
              __result=__line
        return __result        
}

function Net__isUNC(s)
{
#        print "UNC?",s,"?"|"cat 1>&2"
        pat="^//([^/]+)/([^/]+)(/[^/]+)*$"; 
        return (match(s,pat) != 0)
}

function Net__isLogin(s)
{
        pat="^[^@^/]+@([^@^:^/])+(:[^@^:^/]+(/[^@^:^/]*)*+)?$"; 
        return (match(s,pat) != 0)
}

function Net__isIP(s)
{
    pat="^([0-9]*).([0-9]*).([0-9]*).([0-9]*)$"
    return (match(s,pat) != 0)
}

function Net__isHTTP(s)
{
    pat="^https://([^\\.^/^?^:^@^=^&])+(\\.([^\\.^/^?^:^@^=^&])+)+(:[0-9]+)?/?$"
#    pat="^(https?://)?([^\\.^/^?^:^@^=^&])+(\\.([^\\.^/^?^:^@^=^&])+)+(:[0-9]+)?/?$"
    return (match(tolower(s),pat) != 0)
}

function Net__isCurlFtpfs(s)
{
    pat="^curlftpfs#ftp:"
    return (match(tolower(s),pat) != 0)
}


# Tells whether the passed argument looks like a FTP URL, i.e.
# of the basic form ftp://[user@]host

function Net__isFTP(s)
{
    __isftp_pat1="^ftp://([^@]+@)?([^@^:^/])+(:[0-9]*)?(/)?$"
    __isftp_pat2="^curlftpfs#ftp://([^@]+@)?([^@^:^/])+(:[0-9]*)?(/)?$"
    
    return (match(tolower(s),__isftp_pat1) != 0) || (match(tolower(s),__isftp_pat2) != 0)

}

#Tells whether the passed argument looks like an NFS URL, i.e.
#of the basic form nfs://host:share
#@param [1] URL

function Net__isNFSURL(s)
{
    __nfs_pat="^nfs://([^:])+:(/[^/]+)+$"
    return (match(tolower(s),__nfs_pat) != 0)
}


function Net__isNFS(s)
{
    __nfs_pat="^([^:])+:(/[^/]+)+$"
    return (match(tolower(s),__nfs_pat) != 0)
}

function USB__isAdbURL(s)
{
    __pat="^adb://usb(:.+)?$"
    return (match(tolower(s),__pat) != 0)
}

function USB__isAdbDevice(s)
{  
   if (tolower(s)=="adbfs") return 1
    
   __nbAdbDevices=split(s,USB__isAdbDevice_checkFields, " ")

   #log_dbg("USB__isAdbDevice " __nbAdbDevices);        

   if (__nbAdbDevices > 1) {
        if (tolower(USB__isAdbDevice_checkFields[1])=="adbfs") return 1
   }

   return 0
}

function USB__getAdbDeviceStatus(s)
{
   __nbAdbDevices=split(s, USB__isAdbDevice_checkFields, " ")
   if (__nbAdbDevices > 1) {
        return (USB__isAdbDevice_checkFields[2]) 
   }

   return ""
}


function Net__isCloudDevice(s)
{
   if (tolower(s)=="google-drive-ocamlfuse") return 1
   return 0
}

function Net__isCloudURL(s)
{
   if (tolower(s)=="google-drive-ocamlfuse") return 1
   return 0
}


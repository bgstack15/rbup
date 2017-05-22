#!/bin/sh
# Filename: rbup.sh
# Location: /usr/share/rbup/
# Author: bgstack15@gmail.com
# Startdate: 2017-05-21 09:25:16
# Title: Script that Performs Regular Backups
# Purpose: Allows customizable jobs from an easy config file
# Package: rbup
# History: 
#    2016 Basic form for sync_smash.sh designed
# Usage: 
# Reference: ftemplate.sh 2017-04-17a; framework.sh 2017-04-17a
#    /mnt/bgirton/Backups/bup_data.sh which itself was modified from darmok:/usr/local/bin/sync_smash.sh
#    dnskeepalive.sh from package bgscripts-core
# Improve:
#    provide a reverse-direction listing-only mechanism
fiversion="2017-04-29a"
rbupversion="2017-05-21a"

usage() {
   less -F >&2 <<ENDUSAGE
usage: rbup.sh [-duV] [-c <conffile>]
version ${rbupversion}
 -d debug   Show debugging info, including parsed variables.
 -u usage   Show this usage block.
 -V version Show script version number.
 -c conffile Use this conf instead of default, which is /etc/rbup/rbup.conf
Return values:
0 Normal
1 Help or version info displayed
2 Count or type of flaglessvals is incorrect
3 Incorrect OS type
4 Unable to find dependency
5 Not run as root or sudo
6 Already running or problem with lockfile or log dir
7 Invalid checksum(s) on file(s)
8 Unable to mount destination or checksum mismatch
ENDUSAGE
}

# DEFINE FUNCTIONS
get_conf() {
   local _infile="$1"
   local _tmpfile1="$( mktemp )"
   grep -viE '^\s*((#).*)?$' "${_infile}" | while read _line;
   do
      local _left="$( echo "${_line}" | cut -d'=' -f1 )"
      eval "_thisval=\"\${${_left}}\""
      test -z "${_thisval}" && echo "${_line}" >> "${_tmpfile1}"
   done
   test -f "${_tmpfile1}" && . "${_tmpfile1}" 1>/dev/null 2>&1
   /bin/rm -rf "${_tmpfile1}"
}

# DEFINE TRAPS

clean_rbup() {
   #use at end of entire script if you need to clean up tmpfiles
   fistruthy "${RBUP_NO_CLEANUP}" || rm -rf "${tmpdir}" "${lockfile}" 1>/dev/null 2>&1
   :
}

CTRLC() {
   #trap "CTRLC" 2
   [ ] #useful for controlling the ctrl+c keystroke
   clean_rbup
}

CTRLZ() {
   #trap "CTRLZ" 18
   [ ] #useful for controlling the ctrl+z keystroke
}

parseFlag() {
   flag="$1"
   hasval=0
   case ${flag} in
      # INSERT FLAGS HERE
      "d" | "debug" | "DEBUG" | "dd" ) setdebug; ferror "debug level ${debug}";;
      "u" | "usage" | "help" | "h" ) usage; exit 1;;
      "V" | "fcheck" | "version" ) ferror "${scriptfile} version ${rbupversion}"; exit 1;;
      #"i" | "infile" | "inputfile" ) getval;infile1=${tempval};;
      "c" | "conf" | "config" | "conffile" ) getval; conffile="${tempval}";;
      "r" | "n" | "dry" | "dryrun" ) export RBUP_ENABLED=no;;
      "a" | "apply" ) export RBUP_ENABLED=yes;;
      "clean" ) clean_rbup; exit 0;;
   esac
   
   debuglev 10 && { test ${hasval} -eq 1 && ferror "flag: ${flag} = ${tempval}" || ferror "flag: ${flag}"; }
}

# DETERMINE LOCATION OF FRAMEWORK
while read flocation; do if test -x ${flocation} && test "$( ${flocation} --fcheck )" -ge 20170111; then frameworkscript="${flocation}"; break; fi; done <<EOFLOCATIONS
/usr/share/rbup/inc/framework.sh
/usr/share/bgscripts/framework.sh
EOFLOCATIONS
test -z "${frameworkscript}" && echo "$0: framework not found. Aborted." 1>&2 && exit 4

# INITIALIZE VARIABLES
# variables set in framework:
# today server thistty scriptdir scriptfile scripttrim
# is_cronjob stdin_piped stdout_piped stderr_piped sendsh sendopts
. ${frameworkscript} || echo "$0: framework did not run properly. Continuing..." 1>&2
infile1=
outfile1=
default_conffile=/etc/rbup/rbup.conf
conffile="${default_conffile}"
logfile=${scriptdir}/${scripttrim}.${today}.out # not used here. See RBUP_LOG_FILE
interestedparties="bgstack15@gmail.com"
lockfile=/tmp/.rbup.lock

# REACT TO OPERATING SYSTEM TYPE
case $( uname -s ) in
   Linux) [ ];;
   FreeBSD) [ ];;
   *) echo "${scriptfile}: 3. Indeterminate OS: $( uname -s )" 1>&2 && exit 3;;
esac

# REACT TO ROOT STATUS
case ${is_root} in
   1) # proper root
      [ ] ;;
   sudo) # sudo to root
      [ ] ;;
   "") # not root at all
      ferror "${scriptfile}: 5. Please run as root or sudo. Aborted."
      exit 5
      [ ]
      ;;
esac

# SET CUSTOM SCRIPT AND VALUES
#setval 1 sendsh sendopts<<EOFSENDSH      # if $1="1" then setvalout="critical-fail" on failure
#/usr/share/bgscripts/send.sh -hs     #                setvalout maybe be "fail" otherwise
#/usr/local/bin/send.sh -hs               # on success, setvalout="valid-sendsh"
#/usr/bin/mail -s
#EOFSENDSH
#test "${setvalout}" = "critical-fail" && ferror "${scriptfile}: 4. mailer not found. Aborted." && exit 4

# VALIDATE PARAMETERS
# objects before the dash are options, which get filled with the optvals
# to debug flags, use option DEBUG. Variables set in framework: fallopts
validateparams - "$@"

# CONFIRM TOTAL NUMBER OF FLAGLESSVALS IS CORRECT
#if test ${thiscount} -lt 2;
#then
#   ferror "${scriptfile}: 2. Fewer than 2 flaglessvals. Aborted."
#   exit 2
#fi

# CONFIGURE VARIABLES AFTER PARAMETERS

# READ CONFIG FILES
if test -f "${conffile}";
then
   get_conf "${conffile}"
else
   test "${conffile}" = "${default_conffile}" || ferror "${scriptfile}: Ignoring conf file which is not found: ${conffile}."
fi
test -f "${default_conffile}" && get_conf "${default_conffile}"

## REACT TO BEING A CRONJOB
#if test ${is_cronjob} -eq 1;
#then
#   [ ]
#else
#   [ ]
#fi

# EXIT IF LOCKFILE EXISTS
if test -e "${lockfile}";
then
   if /bin/ps -ef | awk '/rbup/{print $2}' | grep -qiE "$( cat "${lockfile}" )";
   then
      ferror "Already running (pid $( cat "${lockfile}" ). Aborted."
      exit 6
   else
      ferror "Previous instance did not exit cleanly."
   fi  
fi

# SET TRAPS
trap "CTRLC" 2
#trap "CTRLZ" 18
trap "clean_rbup" 0

# CREATE LOCKFILE
if ! touch "${lockfile}";
then
   ferror "Could not create lockfile ${lockfile}. Aborted."
   exit 6
else
   echo "$$" > "${lockfile}"
fi

if ! mkdir -p "${RBUP_LOG_DIR}";
then
   ferror "Could not make log dir ${RBUP_LOG_DIR}. Aborted."
   exit 6
fi

# MAIN LOOP
{
   flecho "${scripttrim} STARTED"

   # Show used values
   debuglev 5 && {
      ferror "Using values"
      # used values: RBUP_(NOW|SYNC_CMD|SYNC_OPTS|SYNC_OPT_VERBOSE|SYNC_OPT_APPLY|DEST_MOUNT_CMD|DEST_UMOUNT_CMD|DEST|LOG_DIR|VERBOSE|JOB_NAME|SOURCE|CHECKSUM_COUNT|CHECKSUM_1_FILE|CHECKSUM_1_SHA256SUM|LOG_FILE|NO_CLEANUP)"
      set | grep -iE "^RBUP_" 1>&2
   }

   # flow:
   # 1. confirm checksums are valid
   # 2. mount dest
   # 3. execute rsync
   # 4. umount dest

   # Confirm checksums are valid before running mount command
   _x=0
   if test -n "${RBUP_CHECKSUM_COUNT}" && fisnum "${RBUP_CHECKSUM_COUNT}";
   then
      while test ${_x} -lt ${RBUP_CHECKSUM_COUNT};
      do
         _x=$(( _x + 1 ))
         eval thischeckedfile=\"\${RBUP_CHECKSUM_${_x}_FILE}\"
         eval thissum=\"\${RBUP_CHECKSUM_${_x}_SHA256SUM}\"
         thischeckedfilesum="$( /bin/sha256sum "${thischeckedfile}" | awk '{print $1}' )"
         if test ! "${thischeckedfilesum}" = "${thissum}";
         then
            ferror "ERROR 8. Checksum mismatch for ${thischeckedfile}."
            ferror "Expected checksum: \"${thissum}\""
            ferror "Actual checksum: \"${thischeckedfilesum}\""
            ferror "Aborted."
            exit 8
         else
            debuglev 4 && ferror "Checksum valid for ${thischeckedfile}."
         fi
      done
   fi

   # Mount destination
   if test -n "${RBUP_DEST_MOUNT_CMD}";
   then
      ${RBUP_DEST_MOUNT_CMD} && debuglev 2 && ferror "Mount successful."
   fi

   # Ensure mount is mounted
   if test -n "${RBUP_MOUNT_POINT}";
   then
      if mount | grep -q -- "${RBUP_MOUNT_POINT}";
      then
         :
      else
         ferror "ERROR 8. Failed to mount: ${RBUP_MOUNT_POINT}."
         ferror "Aborted."
         exit 8
      fi
   fi

   # Determine apply and verbose states
   applystate="${RBUP_SYNC_OPT_NOT_APPLY}"
   verbosestate="${RBUP_SYNC_OPT_NOT_VERBOSE}"
   fistruthy "${RBUP_ENABLED}" && applystate="${RBUP_SYNC_OPT_APPLY}"
   fistruthy "${RBUP_VERBOSE}" && verbosestate="${RBUP_SYNC_OPT_VERBOSE}"

   # Prepare full command
   fullcommand="$( echo "${RBUP_SYNC_CMD} ${RBUP_SYNC_OPTS} ${applystate} ${verbosestate} ${RBUP_SOURCE} ${RBUP_DEST}" | sed -r -e 's/[[:space:]]+/ /g;' )"

   # Run sync
   debuglev 1 && {
      ferror "Executing:"
      ferror "${fullcommand}"
   }
   ${fullcommand}

   # Unmount destination
   if test -n "${RBUP_DEST_UMOUNT_CMD}";
   then
      ${RBUP_DEST_UMOUNT_CMD} && debuglev 2 && ferror "Umount successful."
   fi

   flecho "${scripttrim} STOPPED"

} | tee -a ${RBUP_LOG_FILE}

# EMAIL LOGFILE
#${sendsh} ${sendopts} "${server} ${scriptfile} out" ${logfile} ${interestedparties}

## STOP THE READ CONFIG FILE
#exit 0
#fi; done; }

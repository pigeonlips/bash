#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NONE='\033[0m'
LINE_BREAK=$'printf \'%*s\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -i'

LOW_SPACE=()
LOG_FILE="$(dirname $(readlink -f $0) )/logfile.txt"

# build out the commands i want to run for cleaning up
PRE_RUN_COMMANDS=()
PRE_RUN_COMMANDS+=("journalctl --vacuum-time=1d >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("logrotate -vf /etc/logrotate.conf >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("find /var/log -type f -name \"*.xz\" -delete >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("rm /tmp/* -rf >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("snapper cleanup number >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("zypper --non-interactive purge-kernels >> ${LOG_FILE}")
PRE_RUN_COMMANDS+=("zypper --non-interactive clean >> ${LOG_FILE}")
PRE_RUN_ERROR=false

# build out the commands i want to run post successful maintenance
POST_RUN_COMMANDS=()
POST_RUN_COMMANDS+=("snapper create --description 'stable via maintenance script' --cleanup-algorithm number >> ${LOG_FILE} 2>&1")
POST_RUN_COMMANDS+=("zypper --non-interactive dup >> ${LOG_FILE}")
POST_RUN_COMMANDS+=("zypper --non-interactive clean >> ${LOG_FILE}")

# build in some art work !
liz=(32.4 48.1 45.2 48.1 94.12 92.1 95.8 10.1 13.1 32.4 92.1 95.2 47.1 124.2 45.7 124.2 45.9 126.1 10.1 13.1 32.8 96.2 32.7 96.2 10.1 13.1)
clean=(32.6 46.1 45.1 46.1 32.6 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 61.1 124.1 10.1 13.1 32.6 124.1 61.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 10.1 13.1 32.6 124.1 32.1 124.1 32.7 44.1 46.1 45.2 96.1 94.4 96.1 45.2 46.1 44.1 10.1 13.1 32.6 124.1 61.1 124.1 32.6 40.1 96.1 45.1 46.1 44.1 95.5 44.1 46.1 45.1 96.1 47.1 41.1 10.1 13.1 32.6 124.1 61.1 124.1 32.6 92.2 45.1 46.1 44.1 95.5 44.1 46.1 45.1 47.2 10.1 13.1 32.6 124.1 95.1 124.1 32.6 59.1 92.2 32.9 47.2 124.1 10.1 13.1 32.4 46.1 61.1 47.1 73.1 92.1 61.1 46.1 32.4 124.1 32.1 92.2 32.2 95.3 32.2 47.2 32.1 124.1 10.1 13.1 32.3 47.4 86.1 92.4 32.3 124.1 32.2 96.1 45.1 91.1 95.3 93.1 45.1 96.1 32.2 124.1 10.1 13.1 32.3 124.1 35.7 124.1 32.3 124.1 32.13 124.1 10.1 13.1 32.3 124.9 32.4 96.1 45.1 46.1 44.1 95.5 44.1 46.1 45.1 96.1 10.1 13.1)

eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "Tidy, Tidy Away ....\n" | tee --append ${LOG_FILE}
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "\n"
for i in ${clean[@]}; do
  IFS='.' read -ra char <<< $i
  for w in $( seq 1 ${char[1]} ) ; do
    printf "\x$(printf %x ${char[0]})"
  done
done
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "\n"

# check we have permissions (sudo)
if [[ $EUID -ne 0 ]]; then
   printf "~ [${YELLOW}WARN${NONE}] This script was designed to be run under sudo or root. You can check the contents of the script before you do if your worried\n\n"
 read -r -p "Want to exit? no to carry on, but you'll mostly get permission errors [Y/n]" response
 response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    exit 1
 fi
fi

# run our maintenance commands !
for command in "${PRE_RUN_COMMANDS[@]}"; do
  printf "${YELLOW}~ [Running] $command${NONE}\n" >> ${LOG_FILE}
  if eval "$command" ; then
    printf "~ [${GREEN}OK${NONE}] $command\n\n" | tee --append ${LOG_FILE}
  else
    printf "~ [${RED}FAILED${NONE}] $command\n\n" | tee --append ${LOG_FILE}
    PRE_RUN_ERROR=true
  fi
done

# get disk space using df and hold any that are low!
printf "~ [${YELLOW}Running${NONE}] df | grep -e \"[8-9][0-9]%%\" -e \"100%%\" | grep -v \"/home\" | grep -v \"/run/media\"\n" | tee --append ${LOG_FILE}
mapfile -t LOW_SPACE < <(df | grep -e "[8-9][0-9]%" -e "100%" | grep -v "/home" | grep -v "/run/media" )

if [ ${#LOW_SPACE[@]} -gt 0 ] ; then
  printf "~ [${RED}FAIL${NONE}] space is low on the following mounts ! ... \n" | tee --append ${LOG_FILE}
  eval ${LINE_BREAK} | tee --append ${LOG_FILE}
  printf '%s\n' "${LOW_SPACE[@]}\n" | tee --append ${LOG_FILE}
  eval ${LINE_BREAK} | tee --append ${LOG_FILE}
  printf "~ [ ${RED}AYE, GET YA BROOM, YA RAG ~ AN GO ON YA CELL !${NONE} ] ~\n" | tee --append ${LOG_FILE}
  PRE_RUN_ERROR=true
else
  printf "\n~ [${GREEN}OK${NONE}] space is healthy on all mounts\n\n" | tee --append ${LOG_FILE}
fi

# exit if we errored in clean up or are too low on space !
if $PRE_RUN_ERROR
then
  printf "~ [${YELLOW}WARN${NONE}] Pre-check did not go as swimmingly as possible, skipping system snapshot and up date !${NONE}\n" | tee --append ${LOG_FILE}
  exit 1
fi

eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "snapshot and update system ....\n" | tee --append ${LOG_FILE}
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "${GREEN}"
for i in ${liz[@]}; do
  IFS='.' read -ra char <<< $i
  for w in $( seq 1 ${char[1]} ) ; do
    printf "\x$(printf %x ${char[0]})"
  done
done
printf "${NONE}"
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "\n"

# run out post clean up tasks !
for command in "${POST_RUN_COMMANDS[@]}"; do
  printf "~ [${YELLOW}Running${NONE}] $command${NONE}\n" | tee ${LOG_FILE}
  if eval "$command" ; then
    printf "~ [${GREEN}OK${NONE}] $command\n\n" | tee --append ${LOG_FILE}
  else
    printf "~ [${RED}FAILED${NONE}] $command\n\n" | tee --append ${LOG_FILE}
    exit 1
  fi
done

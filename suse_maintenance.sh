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

cleaner=()
cleaner+=('      .-.      ')
cleaner+=('      | |      ')
cleaner+=('      |=|      ')
cleaner+=('      |=|      ')
cleaner+=('      | |      ')
cleaner+=('      | |      ')
cleaner+=('      | |      ')
cleaner+=('      | |      ')
cleaner+=('      | |      ')
cleaner+=('      | |       ,.--`^^^^`--.,')
cleaner+=('      |=|      (`-.,_____,.-`/)')
cleaner+=('      |=|      \\-.,_____,.-//')
cleaner+=('      |_|      ;\\         //|')
cleaner+=('    .=/I\=.    | \\  ___  // |')
cleaner+=('   ////V\\\\   |  `-[___]-`  |')
cleaner+=('   |#######|   |             |')
cleaner+=('   |||||||||    `-.,_____,.-` ')
lizard=()
lizard+=('')
lizard+=('    0--0^^^^^^^^^^^^\________  ')
lizard+=('    \__/||-------||---------~  ')
lizard+=('        ``       ``')
lizard+=('')

#clear
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "Tidy, Tidy Away ....\n" | tee --append ${LOG_FILE}
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
for clean in "${cleaner[@]}"; do
  printf "$clean\n" | tee --append ${LOG_FILE}
done
eval ${LINE_BREAK} | tee --append ${LOG_FILE}

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

# get low disk space using df !
printf "${YELLOW}~ [Running] df | grep -e \"[8-9][0-9]%\" -e \"100%\" | grep -v '/home'${NONE}\n" >> ${LOG_FILE}
mapfile -t LOW_SPACE < <(df | grep -e "[8-9][0-9]%" -e "100%" | grep -v '/home')

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

if $PRE_RUN_ERROR
then
  printf "~ [${YELLOW}WARN${NONE}] Pre-check did not go as swimmingly as possible, skipping system snapshot and up date !${NONE}\n" | tee --append ${LOG_FILE}
  exit 1
fi

eval ${LINE_BREAK} | tee --append ${LOG_FILE}
printf "snapshot and update system ....\n" | tee --append ${LOG_FILE}
eval ${LINE_BREAK} | tee --append ${LOG_FILE}
for liz in "${lizard[@]}"; do
  printf "$liz\n" | tee --append ${LOG_FILE}
done
eval ${LINE_BREAK} | tee --append ${LOG_FILE}

for command in "${POST_RUN_COMMANDS[@]}"; do
  printf "${YELLOW}~ [Running] $command${NONE}\n" >> ${LOG_FILE}
  if eval "$command" ; then
    printf "~ [${GREEN}OK${NONE}] $command\n\n" | tee --append ${LOG_FILE}
  else
    printf "~ [${RED}FAILED${NONE}] $command\n\n" | tee --append ${LOG_FILE}
    exit 1
  fi
done

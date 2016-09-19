#!/bin/sh

TIPJAR=()

# add your tips here v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v

TIPJAR+=("What info ? \033[0;32mjournalctl -b\033[0m to show the journal since last boot ...")
TIPJAR+=("You should run \033[0;32msudo zypper up\033[0m to refresh repos and update the system ...")
TIPJAR+=("Run this \033[0;32msudo snapper create --description 'Uh-Oh'\033[0m before making any big changes ..!")

# add your tips here ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

# Select a random tip
TIP=${TIPJAR[RANDOM%${#TIPJAR[@]}]}

# DONE we should check to see if cowsay is installed
command -v cowsay >/dev/null 2>&1 || { echo -e "${TIP}"; exit 1; }

# DONE Create cow file on the fly
echo '$the_cow = <<"EOC";
        $thoughts    ____
         $thoughts  /@   `~-..
            \\/ .. .-, |
             // //   /
             ^  ^   @

EOC' > $HOME/susetip.cow

# do the work, show a tip
printf "%b " $TIP | cowthink -f $HOME/susetip.cow -W${COLUMNS:-$(tput cols)} | sed -e "s/(/ /g" -e "s/)//g" -e "s/_/-/g"

# tidy up
unset TIP
unset TIPS
rm $HOME/susetip.cow

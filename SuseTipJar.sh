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

## get the number of lines in file
#wc -l < ~/test.txt

## pipe text from file with color to cowsay
#echo -e "$(tail ~/test.txt )" | cowsay

## get forth line from file
#sed "4q;d" ~/test.txt

## get a random number 1 through 10
#$(( ( RANDOM % 10 )  + 1 ))

# putting it all together
# echo -e `sed "$(( ( RANDOM % \`wc -l < ~/test.txt\` )  + 1 ))q;d" ~/test.txt ` | cowsay

# do the work, show a tip
printf "%b " $TIP | cowthink -f $HOME/susetip.cow -W${COLUMNS:-$(tput cols)} | sed -e "s/(/ /g" -e "s/)//g" -e "s/_/-/g"

# tidy up
rm $HOME/susetip.cow
unset TIP
unset TIPS

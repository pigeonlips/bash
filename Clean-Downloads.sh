#!/bin/bash

name=$1
confirm=$2
SOURCEDIR="$HOME/Downloads"
TARGETDIR="$HOME/Videos/"

# TODO Make some checks for all the tools i use (transmission-remote) for example
if [[ -n "$name" ]]; then

    target=`find $TARGETDIR -maxdepth 1 -type d -iname "*$name*"`

    if [ "$target" = "" ]; then

      echo -e "\e[7m Could not find Target in $TARGETDIR ... mkdir one please \e[27m"

    else

      echo -e "\e[33m Target : \e[39m"
      echo -e "\e[36m $target  \e[39m"
      echo -e "\e[33m Files :  \e[39m"

      if [ "$confirm" = "-confirm" ]; then

        # array to hold folders that should be removed ...
        declare -a FoldersArray=()

        # loop through every file i find ...
        while read file;
        do

          # get just the folder of our file ...
          folder=`dirname "$file"`
          filename=`basename "$file"`

          # move the file ...
          mv "$file" "$target" -v

          # now remove from transmission ...
          TORRENTLIST=`transmission-remote --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter=" " --fields=1`

          for TORRENTID in $TORRENTLIST

          do

            if [ -n "`transmission-remote --torrent $TORRENTID -l | grep -F $filename`" ] ; then

              transmission-remote --torrent $TORRENTID --list
              transmission-remote --torrent $TORRENTID --remove

            fi

          done

          if [ "$folder" != $SOURCEDIR ]; then

            # add check to see if there are .part files.
            if [ -f "$folder/*.part" ]; then

                echo -e "preserving folder ... has unfinished downloads"

            else

                # if its not the downloads dir then i propably dont need it any more, add it to list of folders to remove
                FoldersArray+=("$folder")

            fi # end if the folder has .part in it

          fi # end if this isnt the parent folder

        done <<< "$(find ~/Downloads -type f \( -iname "*$name*" ! -iname "*.part" \))"

        for d in "${FoldersArray[@]}"
        do

          # remove all empty folders post move
          rm "$d" -r -v

        done

      else # just list out the files we found

        find $SOURCEDIR -type f \( -iname "*$name*" ! -iname "*.part" \)

        echo -e "\e[7m repeat the command with -confirm at the end to make it so ... \e[27m"

      fi

    fi

else

    echo "What are we cleaning up ? "

fi

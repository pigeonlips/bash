#!/bin/sh

function headphone() {

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BROWN='\033[0;33m'
  LIGHTGREEN='\033[1;32m'
  WHITE='\033[1;37m'
  NOCOLOR='\033[0m'
  AUDIO_SOURCE='alsa_output.pci-0000_00_1b.0.analog-stereo.monitor'
  PORT=8888

  case "$1" in
    start)
      pactl unload-module `pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g'`
      pactl load-module module-simple-protocol-tcp rate=48000 format=s16le channels=2 source=${AUDIO_SOURCE} record=true port=${PORT}
      ;;
    stop)
      pactl unload-module `pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g'`
      ;;
    help)
      echo "Usage: $0 [start|stop]" >&2
      echo
      echo -e "Currently audio source is set to ${GREEN}${AUDIO_SOURCE}${NOCOLOR}. "
      echo -e "You can run ${LIGHTGREEN}pactl list | grep -i 'monitor source:'${NOCOLOR} to find the source name of the sound output. If its diffrent amend the script!"
      echo
      echo -e "running on port ${PORT}"
      ;;
    *)
      echo "Usage: $0 [start|stop]" >&2
      ;;
  esac
  echo
  if [[ $(pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g') ]]
  then
    echo -e "Headphones are currently ${LIGHTGREEN}Running${NOCOLOR} on ip address ${LIGHTGREEN}`hostname -I`${NOCOLOR}, port ${LIGHTGREEN}${PORT}${NOCOLOR}"
    notify-send "Headphones Running on ip address `hostname -I`, port ${PORT}" -i network-cellular-connected
  else
    echo -e "Headphones are currently ${RED}Not Running${NOCOLOR}"
    notify-send  "Headphones Not Running" -i network-cellular-connected
  fi
}

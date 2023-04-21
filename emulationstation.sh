#!/bin/bash
declare -a roms=()
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)

wget -O ~/.emulationstation/custom_systems/es_systems.xml https://raw.githubusercontent.com/WizzardSK/gameflix/main/.emulationstation/custom_systems/es_systems.xml
wget -O ~/.emulationstation/es_controller_mappings.cfg https://raw.githubusercontent.com/WizzardSK/gameflix/main/.emulationstation/es_controller_mappings.cfg
wget -O ~/.emulationstation/es_input.xml https://raw.githubusercontent.com/WizzardSK/gameflix/main/.emulationstation/es_input.xml

mkdir -p ~/media
rm -rf ~/.emulationstation/downloaded_media

rclone mount thumbnails: ~/media --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty

IFS=","
for each in "${roms[@]}"; do
  read -ra rom < <(printf '%s' "$each")
  mkdir -p ~/roms/${rom[0]}
  mkdir -p ~/.emulationstation/downloaded_media/${rom[0]}
  rclone mount ${rom[1]} ~/roms/${rom[0]} --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --vfs-cache-mode full --allow-non-empty --daemon
  ln -s ~/media/${rom[2]} ~/.emulationstation/downloaded_media/${rom[0]}/screenshots
done

archivemount "~/roms/atari800/[ATR]/Atari 8bit - Games - [ATR].zip" ~/roms/atari800

emulationstation &
rclone sync "archive:retroarchbios" ~/.config/retroarch/system

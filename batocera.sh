#!/bin/bash
mount -o remount,size=1000M /overlay
mkdir -p /userdata/system/.config/rclone
wget -O /userdata/system/.config/rclone/rclone.conf https://raw.githubusercontent.com/WizzardSK/gameflix/main/.config/rclone/rclone.conf
if [ ! -f /userdata/system/mount-zip ]; then wget -O /userdata/system/mount-zip https://github.com/WizzardSK/gameflix/raw/main/batocera/share/system/mount-zip; chmod +x /userdata/system/mount-zip; fi
wget -O /usr/share/emulationstation/es_systems.cfg https://github.com/WizzardSK/gameflix/raw/main/batocera/share/system/es_systems.cfg
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)

emulationstation stop; chvt 3; clear

rm -rf /userdata/roms
mkdir -p /userdata/roms
mkdir -p /userdata/thumbs
mkdir -p /userdata/rom
mkdir -p /userdata/rom/No-Intro
mkdir -p /userdata/rom/Redump
mkdir -p /userdata/rom/TOSEC

rclone mount thumbnails: /userdata/thumbs --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf
rclone mount myrient:No-Intro /userdata/rom/No-Intro --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf
rclone mount myrient:Redump /userdata/rom/Redump --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --daemon --config=/userdata/system/.config/rclone/rclone.conf
rclone mount myrient:TOSEC /userdata/rom/TOSEC --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf

IFS=","
for each in "${roms[@]}"; do
  read -ra rom < <(printf '%s' "$each")
  echo "Mounting ${rom[0]}"
  mkdir -p /userdata/roms/${rom[0]}/online
  mkdir -p /userdata/roms/${rom[0]}/images  
  if grep -q ":" <<< "${rom[1]}"; then
    rclone mount ${rom[1]} /userdata/roms/${rom[0]}/online --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf
  else
    mount -o bind /userdata/rom/${rom[1]} /userdata/roms/${rom[0]}/online
  fi  
  mount -o bind /userdata/thumbs/${rom[2]}/Named_Snaps /userdata/roms/${rom[0]}/images
done
for each in "${zips[@]}"; do
  read -ra zip < <(printf '%s' "$each")
  echo "Mounting ${zip[0]}"
  mkdir -p /userdata/roms/${zip[0]}/online
  mkdir -p /userdata/roms/${zip[0]}/images
  /userdata/system/mount-zip /userdata/rom/${zip[1]} /userdata/roms/${zip[O]}/online -o nonempty -omodules=iconv,from_code=$charset1,to_code=$charset2
  mount -o bind /userdata/thumbs/${zip[2]}/Named_Snaps /userdata/roms/${zip[0]}/images
done

chvt 2; curl http://127.0.0.1:1234/reloadgames

#!/bin/bash
ln -s /usr/bin/fusermount /usr/bin/fusermount3
curl -s -L https://rclone.org/install.sh | bash
if [ ! -f /userdata/system/.config/rclone/rclone.conf ]; then wget -O /userdata/system/.config/rclone/rclone.conf https://raw.githubusercontent.com/WizzardSK/gameflix/main/.config/rclone/rclone.conf; fi
declare -a roms=()
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)

emulationstation stop
chvt 3
clear

mkdir -p /userdata/thumbs
rclone mount thumbnails: /userdata/thumbs --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf
IFS=","
for each in "${roms[@]}"; do
  read -ra rom < <(printf '%s' "$each")
  echo "Mounting ${rom[0]}"
  mkdir -p /userdata/roms/${rom[0]}/online
  mkdir -p /userdata/roms/${rom[0]}/images
  rclone mount ${rom[1]} /userdata/roms/${rom[0]}/online --no-checksum --no-modtime --dir-cache-time 100h --allow-non-empty --attr-timeout 100h --poll-interval 100h --vfs-cache-mode full --daemon --config=/userdata/system/.config/rclone/rclone.conf
  mount -o bind /userdata/thumbs/${rom[2]} /userdata/roms/${rom[0]}/images
done

chvt 2
curl http://127.0.0.1:1234/reloadgames
rclone sync archive:retroarchbios /userdata/bios --config=/userdata/system/.config/rclone/rclone.conf

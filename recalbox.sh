#!/bin/bash
ln -s /usr/bin/fusermount /usr/bin/fusermount3
mount -o remount,rw /

case $( uname -m ) in
  armv7l)
    ziparch="arm"
    rclarch="arm-v7"
  ;;
  aarch64)
    ziparch="arm64"
    rclarch="arm64"
  ;;
  x86_64)
    ziparch="x64"
    rclarch="amd64"
  ;;
  i386)
    ziparch="ia32"
    rclarch="386"
  ;;
esac

if [ ! -f /usr/bin/7za ]; then
  wget -O /usr/bin/7za https://github.com/develar/7zip-bin/raw/master/linux/${ziparch}/7za
  chmod +x /usr/bin/7za
fi

if [ ! -f /usr/bin/rclone ]; then
  wget https://downloads.rclone.org/rclone-current-linux-${rclarch}.zip
  7za e -y rclone-current-linux-${rclarch}.zip
  mv rclone /usr/bin/
  chmod +x /usr/bin/rclone
  rm rclone-current-linux-${rclarch}.zip
fi

mkdir -p /recalbox/share/system/.config/rclone
if [ ! -f /recalbox/share/system/.config/rclone/rclone.conf ]; then wget -O /recalbox/share/system/.config/rclone/rclone.conf https://raw.githubusercontent.com/WizzardSK/gameflix/main/.config/rclone/rclone.conf; fi
declare -a roms=()
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)

es stop
chvt 3
clear

mkdir -p /recalbox/share/thumbs
rclone mount thumbnails: /recalbox/share/thumbs --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty

IFS=","
for each in "${roms[@]}"; do
  read -ra rom < <(printf '%s' "$each")
  echo " Mounting ${rom[0]}"
  mkdir -p /recalbox/share/roms/${rom[0]}/online
  rclone mount ${rom[1]} /recalbox/share/roms/${rom[0]}/online --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty
  > /recalbox/share/roms/${rom[0]}/gamelist.xml
  echo "<gameList>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
  ls /recalbox/share/roms/${rom[0]}/online${rom[3]} | while read line; do
    if [[ ! ${line} =~ .*\.(jpg|png|torrent|xml|sqlite|mp3|ogg) ]]; then 
      line2=${line%.*}
      echo "<game><path>online${rom[3]}/${line}</path><image>../../thumbs/${rom[2]}/${line2}.png</image></game>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
    fi
  done
  echo "</gameList>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
done

wget -O /recalbox/share/roms/mame/gamelist.xml https://raw.githubusercontent.com/WizzardSK/gameflix/main/recalbox/share/roms/mame/gamelist.xml

chvt 1
es start
rclone sync "archive:recalbox-bios" /recalbox/share/bios --config=/recalbox/share/system/.config/rclone/rclone.conf

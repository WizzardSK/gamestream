#!/bin/bash
ln -s /usr/bin/fusermount /usr/bin/fusermount3
mount -o remount,rw /

case $( uname -m ) in
  armv7l) ziparch="arm"; rclarch="arm-v7" ;;
  aarch64) ziparch="arm64"; rclarch="arm64" ;;
  x86_64) ziparch="x64"; rclarch="amd64" ;;
  i386) ziparch="ia32"; rclarch="386" ;;
esac

if [ ! -f /usr/bin/7za ]; then wget -O /usr/bin/7za https://github.com/develar/7zip-bin/raw/master/linux/${ziparch}/7za; chmod +x /usr/bin/7za; fi
if [ ! -f /usr/bin/mount-zip ]; then wget -O /usr/bin/mount-zip https://github.com/WizzardSK/gameflix/raw/main/recalbox/share/system/mount-zip; chmod +x /usr/bin/mount-zip; fi
if [ ! -f /usr/bin/rclone ]; then
  wget -O /usr/bin/rclone.zip https://downloads.rclone.org/v1.60.0/rclone-v1.60.0-linux-${rclarch}.zip
  7za e -y /usr/bin/rclone.zip
  mv rclone /usr/bin
  chmod +x /usr/bin/rclone
  rm /usr/bin/rclone.zip
fi

wget -O /recalbox/share_init/system/.emulationstation/systemlist.xml https://github.com/WizzardSK/gameflix/raw/main/recalbox/share/system/systemlist.xml
mkdir -p /recalbox/share/system/.config/rclone
wget -O /recalbox/share/system/.config/rclone/rclone.conf https://raw.githubusercontent.com/WizzardSK/gameflix/main/.config/rclone/rclone.conf
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)

es stop; chvt 3; clear

rm -rf /recalbox/share/roms
mkdir -p /recalbox/share/roms
mkdir -p /recalbox/share/thumbs
mkdir -p /recalbox/share/rom
mkdir -p /recalbox/share/rom/No-Intro
mkdir -p /recalbox/share/rom/Redump
mkdir -p /recalbox/share/rom/TOSEC

rclone mount thumbnails: /recalbox/share/thumbs --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty
rclone mount myrient:No-Intro /recalbox/share/rom/No-Intro --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty
rclone mount myrient:Redump /recalbox/share/rom/Redump --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty
rclone mount myrient:TOSEC /recalbox/share/rom/TOSEC --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty

IFS=";"
for each in "${roms[@]}"; do
  read -ra rom < <(printf '%s' "$each")
  echo "Mounting ${rom[0]}"
  mkdir -p /recalbox/share/roms/${rom[0]}/online  
  if grep -q ":" <<< "${rom[1]}"; then
    rclone mount ${rom[1]} /recalbox/share/roms/${rom[0]}/online --config=/recalbox/share/system/.config/rclone/rclone.conf --daemon --vfs-cache-mode full --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --allow-non-empty
  else
    mount -o bind /recalbox/share/rom/${rom[1]} /recalbox/share/roms/${rom[0]}/online
  fi
  > /recalbox/share/roms/${rom[0]}/gamelist.xml
  echo "<gameList>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
  ls /recalbox/share/roms/${rom[0]}/online | while read line; do
    if [[ ! ${line} =~ .*\.(jpg|png|torrent|xml|sqlite|mp3|ogg) ]]; then 
      line2=${line%.*}
      echo "<game><path>online/${line}</path><image>../../thumbs/${rom[2]}/Named_Snaps/${line2}.png</image></game>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
    fi
  done
  echo "</gameList>" >> /recalbox/share/roms/${rom[0]}/gamelist.xml
done
for each in "${zips[@]}"; do
  read -ra zip < <(printf '%s' "$each")
  echo "Mounting ${zip[0]}"
  mkdir -p /recalbox/share/roms/${zip[0]}/online
  mount-zip /recalbox/share/rom/${zip[1]} /recalbox/share/roms/${zip[O]}/online -o nonempty -omodules=iconv,from_code=$charset1,to_code=$charset2
  > /recalbox/share/roms/${zip[0]}/gamelist.xml
  echo "<gameList>" >> /recalbox/share/roms/${zip[0]}/gamelist.xml
  ls /recalbox/share/roms/${zip[0]}/online | while read line; do
    if [[ ! ${line} =~ .*\.(jpg|png|torrent|xml|sqlite|mp3|ogg) ]]; then
      line2=${line%.*}
      echo "<game><path>online/${line}</path><image>../../thumbs/${zip[2]}/Named_Snaps/${line2}.png</image></game>" >> /recalbox/share/roms/${zip[0]}/gamelist.xml;
    fi
  done
  echo "</gameList>" >> /recalbox/share/roms/${zip[0]}/gamelist.xml
done

chvt 1; es start

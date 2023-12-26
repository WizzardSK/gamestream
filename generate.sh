#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/platforms.txt)
IFS=";"
echo "<div id=\"topbar\"><h3 id=\"platforma\">gameflix</h3></div><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\" /><br /><br /><br />" > ~/systems.html
cp ~/systems.html ~/main.html
echo "<title>gameflix</title><frameset border=0 cols='240, 100%'><frame name='menu' src='systems.html'><frame name='main' src='main.html'></frameset>" > ~/gameflix.html
wget -O ~/retroarch.sh https://raw.githubusercontent.com/WizzardSK/gameflix/main/retroarch.1st
for each in "${roms[@]}"; do
  ((platforms++))
  read -ra rom < <(printf '%s' "$each")
  if grep -q ":" <<< "${rom[1]}"; then
    mkdir -p ~/roms/${rom[0]}
    rclone mount ${rom[1]} ~/roms/${rom[0]} --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --vfs-cache-mode full --allow-non-empty --daemon
  fi
  > ~/${rom[0]}.html
  #> ~/${rom[0]}.txt
  wget -O ~/${rom[0]}.html https://raw.githubusercontent.com/WizzardSK/gameflix/main/platform.html
  pocet=0    
  if [ "${rom[0]}" = "dos" ]; then rom[1]="../roms/dos"; fi
  {
    while IFS= read -r line; do
      if [[ ! ${line} =~ \[BIOS\] ]]; then
        ahref=$(echo "$line" | sed -e "s/'/\\\'/g")
        thumb=$(echo "$line" | sed -e 's/&/_/g' -e "s/'/\\\'/g" -e 's/#/%23/g')
        echo "<figure onclick=\"window.location.href='myrient/${rom[1]}/${ahref}'\"><img loading=lazy src=\"http://thumbnails.libretro.com/${rom[2]}/Named_Snaps/${line%.*}.png\"><figcaption>${line%.*}</figcaption></figure>" >> ~/${rom[0]}.html
        #echo ${line} >> ~/${rom[0]}.txt;
        ((pocet++))
        ((total++))
      fi
    done
  } < <(ls ~/myrient/${rom[1]})
  echo "</div><script src=\"script.js\"></script>" >> ~/${rom[0]}.html
  echo "<a href='${rom[0]}.html' target='main' onclick=\"document.getElementById('platforma').innerHTML = this.innerText\">${rom[3]}</a> ($pocet)<br />" >> ~/systems.html
  echo "<figure><img src='https://raw.githubusercontent.com/libretro/retroarch-assets/master/xmb/monochrome/png/"${rom[2]}".png'><figcaption><a href='${rom[0]}.html' target='main'>${rom[3]}</a> ($pocet)</figcaption></figure>" >> ~/main.html
  ext=""
  if [ -n "${rom[5]}" ]; then ext="; ext=\"${rom[5]}\""; fi
  echo "\"${rom[1]##*/}\") core=\"${rom[4]}\"${ext};;" >> ~/retroarch.sh
done
for each in "${zips[@]}"; do
  ((platforms++))
  read -ra zip < <(printf '%s' "$each")
  mkdir -p ~/roms/${zip[0]}
  mount-zip ~/myrient/${zip[1]} ~/roms/${zip[O]} -o nonempty -omodules=iconv,from_code=$charset1,to_code=$charset2
  > ~/${zip[0]}.html
  #> ~/${zip[0]}.txt
  wget -O ~/${zip[0]}.html https://raw.githubusercontent.com/WizzardSK/gameflix/main/platform.html
  pocet=0
  {
    while IFS= read -r line; do
      if [[ ! ${line} =~ \[BIOS\] ]]; then
        ahref=$(echo "$line" | sed -e "s/'/\\\'/g")
        thumb=$(echo "$line" | sed -e 's/&/_/g' -e "s/'/\\\'/g")    
        echo "<figure onclick=\"window.location.href='roms/${zip[0]}/${ahref}'\"><img loading=lazy src=\"http://thumbnails.libretro.com/${zip[2]}/Named_Snaps/${line%.*}.png\"><figcaption>${line%.*}</figcaption></figure>" >> ~/${zip[0]}.html
        #echo ${line} >> ~/${zip[0]}.txt;        
        ((pocet++))
        ((total++))
      fi
    done
  } < <(ls ~/roms/${zip[0]})
  echo "</div><script src=\"script.js\"></script>" >> ~/${zip[0]}.html
  echo "<a href='${zip[0]}.html' target='main' onclick=\"document.getElementById('platforma').innerHTML = this.innerText\">${zip[3]}</a> ($pocet)<br />" >> ~/systems.html  
  echo "<figure><img src='https://raw.githubusercontent.com/libretro/retroarch-assets/master/xmb/monochrome/png/"${zip[2]}".png'><figcaption><a href='${zip[0]}.html' target='main'>${zip[3]}</a> ($pocet)</figcaption></figure>" >> ~/main.html  
  ext=""
  if [ -n "${zip[5]}" ]; then ext="; ext=\"${zip[5]}\""; fi
  echo "\"${zip[0]}\") core=\"${zip[4]}\"${ext};;" >> ~/retroarch.sh
done
curl -s https://raw.githubusercontent.com/WizzardSK/gameflix/main/retroarch.end | tee -a ~/retroarch.sh  
chmod +x ~/retroarch.sh
echo "<p><b>Total: $total</b>" >> ~/systems.html
echo "<p><b>Platforms: $platforms</b>" >> ~/systems.html

#!/bin/bash
params="--config=/userdata/system/.config/rclone/rclone.conf --no-checksum --no-modtime --attr-timeout 100h --dir-cache-time 100h --poll-interval 100h --vfs-cache-mode full --allow-non-empty --daemon"

/userdata/system/rclone mount "myrient:No-Intro/Atari - 2600" /userdata/roms/atari2600/online $params
/userdata/system/rclone mount "myrient:No-Intro/Atari - 5200" /userdata/roms/atari5200/online $params
/userdata/system/rclone mount "myrient:No-Intro/Atari - 7800" /userdata/roms/atari7800/online $params
/userdata/system/rclone mount "myrient:No-Intro/Atari - Jaguar (J64)" /userdata/roms/jaguar/online $params
/userdata/system/rclone mount "myrient:No-Intro/Atari - Lynx" /userdata/roms/lynx/online $params
/userdata/system/rclone mount "myrient:No-Intro/Atari - ST" /userdata/roms/atarist/online $params

curl http://127.0.0.1:1234/reloadgames

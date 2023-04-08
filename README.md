# gameflix

Project for running games directly from public online sources on Linux machines.

I made this project for my own personal needs, to have the same setup on all my machines.

`rclone` binary is needed on host system (version 1.60+). Also it is needed to have rclone configured for all the remotes. Attached [rclone.conf](/.config/rclone/rclone.conf) should be placed in `~/.config/rclone/` with Archive S3 keys added from https://archive.org/account/s3.php If your version is not up to date, grab it from here: https://rclone.org/downloads/

All games are stored on public services Internet Archive and Myrient. Thumbnails are used from https://thumbnails.libretro.com/ configured to use with ES-DE frontend. BIOS files are also synced from remote sources after EmulationStation start. My goal is to have all needed BIOS files available without manual copying from external places. The Retroarch BIOS folder is synced from Internet Archive.

[es_systems.xml](.emulationstation/custom_systems/es_systems.xml) is used to configure roms directories for your emulators and alternative emulators for ES-DE frontend. It is updated automatically from this repository when running mount script.

Why is it better than to have all games on local storage? You may have the access to all your games without the need to have a huge storage. Some PSX, PS2, GameCube or Dreamcast games may be very large and using this script you may run them on a Chromebook with small storage (if it may run those emulators). The disadvantage is that you need fast internet connection and even with that the loading of bigger games may be quite slow.

## Usage - EmulationStation DE
Run [mount.sh](mount.sh) or `emulationstation.sh` or `bash <(curl -Ls https://raw.githubusercontent.com/WizzardSK/gameflix/main/emulationstation.sh)` to mount the library.

The library is mounted into `roms` folder in your home directory. If roms directories do not exist, they are automatically created.

Then use the library with any emulation system like Retroarch. It is up to you how you configure the emulators. I am using https://es-de.org/ on Linux on my arm Chromebook, what is basically EmulationStation Desktop Edition suitable for desktop computers, including arm.

Now you may run the roms directly without copying them to local storage, just like Netflix. 

Run [unmount.sh](unmount.sh) or `unroms.sh` or `bash <(curl -Ls https://raw.githubusercontent.com/WizzardSK/gameflix/main/unroms.sh)` to unmount the library or it is unmounted after restart.

## Usage - Batocera Linux
For Batocera, you need to copy [custom.sh](batocera/share/system/custom.sh) file to your system folder in shared drive. It will launch automatically at system boot. It should also install rclone binary and rclone config file in ./config/rclone folder in system folder. Thumbnail folders are mounting too. It is necessary to enable "Search for local art" option in Advanced Settings - Developer Options.

## Usage - Recalbox
For Recalbox, you need to copy [custom.sh](recalbox/share/system/custom.sh) file to your system folder in shared drive. Recalbox is not well supported because it seem to use inotify subsystem for handling file operations what is not supported on fuse filesystems. It is possible to mount remote shares, but Recalbox does not update the gamelists with these games. So the game lists are generated in the script instead of Recalbox itself. Thumbnail folders are mounted too.

> [!CAUTION]
> **THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. BY USING IT YOU TAKE ALL THE RISKS FOR YOUR ACTIONS**

# Rinkhals

Rinkhals is a custom firmware for the Anycubic Kobra 3 3D printer. The goal of this project is to create a simple and safe overlay for the Kobra 3 firmware, adding some usefule features.
Multiple versions can be installed at the same time and it can easily be disabled.

Here is a list of the features I added:
- Mainsail, Fluidd and Moonraker (using nginx)
- USB camera support through Fluidd and Moonraker (mjpg-streamer)
- Print from Moonraker will show the print screen (moonraker-proxy)
- Access using SSH and ADB

This project is named after rinkhals. They are a sub-species of Cobras ... Kobra 3 ... Rinkhals 👏

The stock firmwares are available on a separate branch: https://github.com/jbatonnet/Rinkhals/tree/stock-firmwares


<p align="center">
    <img width="48" src="https://github.com/jbatonnet/Rinkhals/blob/master/icon.png?raw=true" />
</p>


## Known issues / Future developments

The [wiki](https://github.com/jbatonnet/Rinkhals/wiki) is a collection of documentation, reverse engineering and notes about the printer and development, don't forget to [check it out](https://github.com/jbatonnet/Rinkhals/wiki)!

- If not installed properly, the printer shows a 11407 error > [See the wiki about error 11407](https://github.com/jbatonnet/Rinkhals/wiki/Firmware#my-printer-shows-a-11407-error)
- The camera is not accessible from Anycubic apps anymore
- Mainsail/Fluidd gcode preview doesn't work
- OctoApp notification plugin is missing

Other:
- Check free space before install
- Buildroot / FFmpeg with freetext, mjpeg, fbdev, png, bmp, h264
- Installation screen (kill K3SysUi, show screens then reboot or restore K3SysUi?)
- Reimplement gkcam
- Timelapse support
- Logs cleanup
- Old Rinkhals versions cleanup


## SWU tools

This repo contains some tools you can use **no matter what firmware you are using**. It is a set of scripts packaged in a SWU file.

They are available on this page: https://github.com/jbatonnet/Rinkhals/actions/workflows/build-swu-tools.yml

You can download the SWU file for the tool you want, copy it on a FAT32 USB drive in a **aGVscF9zb3Nf** directory, plug the USB drive in the Kobra and it just works.
You will ear two beeps, the second one will tell you that the tool completed its work. There is no need to reboot afterwards.

Here are the tools available:
- **SSH**: get a SSH server running on port **2222**, even on stock firmware
- **Backup partitions**: creates a dump of your userdata and useremain partition on the USB drive
- **Debug bundle**: creates a zip file with printer and configuration information on the USB drive to ease debugging


<p align="center">
    <img width="48" src="https://github.com/jbatonnet/Rinkhals/blob/master/icon.png?raw=true" />
</p>


## How to install Rinkhals

You can install Rinkhals on top of other custom firmwares. Rinkhals only appends its loader to **start.sh**, so if it's the last instruction, it will start no matter what firmware you are using.

- Make sure your printer uses firmware 2.3.5.3 ([how to install firmware](https://github.com/jbatonnet/Rinkhals/wiki/Firmware#how-to-install-a-firmware))
    - Installation will simply fail without touching your printer if you are using some other version
- Format a USB drive as FAT32
- Create a directory named **aGVscF9zb3Nf**
- Download the version of Rinkhals you want to install
- Copy the **update.swu** file in the **aGVscF9zb3Nf** directory
- Plug the USB drive in the Kobra 3
- You should hear a beep, meaning the printer detected the update file
- After about 20 seconds (the time for the printer to prepare the update), you will see a progress bar on the screen
    - If the progress bar turns green and you ear 2 beeps, the pritner reboots and Rinkhals is installed
    - If the progress bar turns red and you ear 3 beeps, the installation failed but everyhting should still work as usual. You will then find more information on the **aGVscF9zb3Nf/install.log** file on the USB drive


## How to uninstall Rinkhals

### 1. Disable Rinkhals

**Method 1**: Create a .disable-rinkhals file on a USB drive or at this location: /useremain/rinkhals/.disable-rinkhals
This will prevent Rinkhals from starting.

**Method 2**: Factory reset might have done that already, but make sure your /userdata/app/gk/start.sh and /userdata/app/gk/restart_k3c.sh don't contain a # Rinkhals/begin section. If they do, remove the section between # Rinkhals/begin and # Rinkhals/end.

### 2. Reboot
Reboot once Rinkhals is disabled to make sure it didn't start, so you'll be able to remove the files.

### 3. Delete Rinkhals
Then you can delete the /useremain/rinkhals directory. That's it!


<p align="center">
    <img width="48" src="https://github.com/jbatonnet/Rinkhals/blob/master/icon.png?raw=true" />
</p>


## Repo structure

- **doc/**: Some documentation I gathered on my journey
- **build/**: The tools, scripts and Dockerfiles needed to build this project
    - **1-buildroot/**: Buildroot setup to build the base filesystem / binaries
    - **2-external/**: Scripts to get the external components like Fluidd and Mainsail
    - **3-python/**: Dockerfile and script to build and get the necessary Python packages
- **files/**: The target filesystem overlay and the scripts needed to run the firmware
    - **1-buildroot/**: First layer containing Buildroot built binaries
    - **2-external/**: External components layer for Fluidd, Mainsail, Moonraker and OctoApp
    - **3-python/**: Layer with all the necessary Python packages
    - **4-rinkhals/**: Fimware config and scripts to run Rinkhals


## Firmware startup

During this custom firmware installation, **update.sh** will install the overlay filesystem in **/useremain/rinkhals**. Every version you install will end up in a different directory, allowing you to easily switch between versions or rollback if something goes wrong.

Then **start.sh.patch** if appended at the end of the default startup scripts. Its goal is to check Rinkhals installation with minimal modification and run **start-rinkhals.sh**.

**start-rinkhals.sh** will now check for the requested version in **/useremain/rinkhals/.version**, check for a **.disable-rinkhals** file on a USB drive if needed and then run the actual Rinkhals loader for the selected version.


## Development

If you want to fully build this firmware yourself and avoid using the prebuilt binaries, you will need to do the following:

- Layer 1: Buildroot (**files/1-buildroot**)
    - Build and run `build/buildroot/Dockerfile` or start your own instance
        - Some run examples are provider in the Dockerfile
    - Use the `build/buildroot/.config` Buildroot configuration file to build the base filesystem binaries
    - Use `build/buildroot/build-target.sh` to filter and extract the files in `/output`

- Layer 2: External apps (**files/2-external**)
    - Update git submodules
    - Build **files/2-external/Dockerfile** if you want
    - `docker run --rm -it -v .\build:/build -v .\files:/files ghcr.io/jbatonnet/rinkjals/build /build/2-external/get-external.sh`

- Layer 3: Python packages for Moonraker (**files/3-python**)
    - Build **files/3-python/Dockerfile** if you want
    - `docker run --privileged --rm tonistiigi/binfmt --install all`
    - `docker run --rm -it -v .\build:/build -v .\files:/files ghcr.io/jbatonnet/rinkjals/python /build/3-python/copy-output.sh`

If you want to quickly iterate on development, a quick deployment method is provided:

- To synchronize your copy of Rinkhals on the printer, run `docker run --rm -it -e KOBRA_IP=x.x.x.x -v .\build:/build -v .\files:/files --entrypoint=/bin/sh rclone/rclone:1.68.2 /build/deploy-dev.sh`
- On the printer, update **/useremain/rinkhals/.version** to `dev`
- On the printer, run `/useremain/rinkhals/start-rinkhals.sh` to manually start Rinkhals


## Thanks

Thanks to the following projects/persons:
- utkabobr (https://github.com/utkabobr/DuckPro-Kobra3)
- systemik (https://github.com/systemik/Kobra3-Firmware/blob/main/update-preparation/cfw/scripts/led-on.sh)
- Icon created by Freepik - Flaticon (https://www.flaticon.com/free-icons/snake)

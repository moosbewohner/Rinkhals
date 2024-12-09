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

- If not installed properly, the printer shows a 11407 error > See the section about error 11407 below
- The camera is not accessible from Anycubic apps anymore
- Mainsail/Fluidd gcode preview doesn't work
- OctoApp notification plugin is missing

Other:
- Build the SWU file and make sure SSH works all the way
- Check free space before install
- Buildroot / FFmpeg with freetext, mjpeg, fbdev, png, bmp, h264
- Installation screen (kill K3SysUi, show screens then reboot or restore K3SysUi?)
- Reimplement gkcam
- Timelapse support
- Logs cleanup
- Old Rinkhals versions cleanup
- Packaging + Auto version names + Github actions


<p align="center">
    <img width="48" src="https://github.com/jbatonnet/Rinkhals/blob/master/icon.png?raw=true" />
</p>


## How to install a firmware

At this point you should have a .swu file, either a stock firmware or a custom one.

- Format a USB drive as FAT32
- Create a new directory
    - If the firmware is based on 2.3.3.9 or later (most firmwares should now), name it **aGVscF9zb3Nf**
    - If it's an older one before 2.3.3.9, name it **update**
- Copy your .swu file in this directory as **update.swu**
- Plug the USB drive in the Kobra 3
- You should hear a beep, meaning the printer detected the firmware file
- Give the printer some time
- Then it should reboot itself. If it doesn't, wait 20~30 minutes then reboot the printer manually
- Once installed, the update.swu file will have been removed from the USB drive, you can check as a confirmation

> [!NOTE]
> When installing Rinkhals, you will ear one beep, then ~10s later a progress will show up on screen. <br />
  Once you ear two beeps or when the progress bar is full green, the installation is complete and the printer will reboot. <br />
  If you ear 3 beeps or the progress bar is full red, the installation failed but everything should still work. You will find the installation logs on the USB drive.

## My printer shows a 11407 error

Don't worry, you can still re-flash stock firmware and try again.
Here is the full process to recover from this state:

- Reflash the stock 2.3.3.9 firmware (https://github.com/jbatonnet/Rinkhals/tree/stock-firmwares)
- Do a factory reset from the printer touchscreen (Settings > Device information > System restore)
- Once done, let the printer update itself to 2.3.5.3 or flash the stock 2.3.5.3 firmware
- Then perform the regular installation described above

> [!NOTE]
> Even if you get 11407 using a 2.5.3.5 firmware, you might need to downgrade to 2.3.3.9 to recover. Please follow all the steps listed above


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

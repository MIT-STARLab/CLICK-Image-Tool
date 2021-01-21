# CLICK Image Tool
Tool to generate the golden image to be flashed on the Raspberry Pi. It cross-compiles a cut-down Linux system with a few packages using [buildroot](https://buildroot.org/).

## Instructions
1. A linux host with git, subversion and device-tree-compiler installed is needed (WSL works too)
2. Configure the top-level variables in `build.sh`
3. To start the image build, run `./build.sh`
4. On first run, the build can take up to an hour, depending on computing power
5. Final images will appear in the `img/` folder
6. `click_emmc.img` is the raw eMMC file that can be flashed using rpiboot with a Compute Module IO board
7. `click_golden.img` is the golden image that includes the usbboot bootloader for VNC2L. This is the golden image to be uplinked to the BCT bus.
8. The default root password is `lasercom`. CLICK SSH keys can also be used to log in using SSH without a password when in debug mode.

## Overview
- `build.sh` is the main script that executes buildroot. It has a variable `CLICK_FSW_VERSION` defining which flight software version to bundle, and `BOOT_WITH_PPP` which can be used to generate an image that boots in debugging mode with PPP/SSH running.
- `config_buildroot.txt` contains buildroot config flags. Defines how to build the system, which Linux kernel git commit to use (`BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION`), which packages to include in the system (`BR2_PACKAGE_xxx`), and some other basic configuration. Can be modified to add more software packages if needed.
- `config_kernel.txt` contains Linux kernel config flags. Defines which kernel modules are bundled with the kernel image and which are built as external modules. Mostly disables a lot of unneeded kernel features and drivers to make the image smaller. Should not need changing.
- `config_rpi.txt` is the config for the RPi bootloader. Sets a static GPU clock to fix SPI frequency and configures the SPI using the device tree overlay from the SPI driver.
- `extra/` contains definitions for custom/uncommon packages that are not included in buildroot by default, such as the custom flight software, Matrix Vision libraries, and the png2jpeg tool. Each folder in `extra/package/` has makefiles that define how the package is downloaded, built and installed to the image. More uncommon software packages can be defined here.
- `overlay/` is a custom tree of files that are added directly to the OS partition by buildroot. These include some system config files and OS services and the FPGALink libraries.
- `post_build.sh` is a script that is automatically executed after buldroot is done with all package compilation. It does some OS configuration before the OS is packaged.
- `post_image.sh` is a script that is automatically executed after buldroot packages the OS. It creates the images with all the partitions, which can be directly flashed onto the RPi.

## Partitions
The final image (~20 MB) contains three partitions:
1. boot (~3 MB), a FAT-16 filesystem with the bootloader files and the (compressed) kernel image.
2. OS (~17 MB), a [SquashFS](https://en.wikipedia.org/wiki/SquashFS) compressed read-only filesystem that contains all the other OS files and packages, including the "golden" CLICK flight software files.
3. RW (3.7 GB), an empty EXT4 read-write filesystem that is created on first boot. The image only contains its partition table entry, not any data.

## Filesystem handling
The way the OS handles the filesystems is explained below:
1. The OS is configured to only use the root user account.
2. The original root user files, including the golden CLICK FSW, are stored read-only at `/usr/local/fsw`.
3. On first boot, the read-write EXT4 filesystem is created and mounted on `/mnt`, see [fs-initialize.service](overlay/usr/lib/systemd/system/fs-initialize.service) and [mnt.mount](overlay/usr/lib/systemd/system/mnt.mount).
4. Next, an [overlay filesystem](https://wiki.archlinux.org/index.php/Overlay_filesystem) is automatically mounted on `/root`. The overlay filesystem will mirror all the read-only files from `/usr/local/fsw`, but allow overwriting them within `/root`, see [root.mount](overlay/usr/lib/systemd/system/root.mount). However, all the changes are actually kept behind the scenes on `/mnt/overlay` (this is invisible to the user). This allows making changes to the original root user files and the CLICK FSW without needing changes on the read-only filesystem.
5. All manual file modifications or new data storing should be done directly on `/root`. The `/mnt` directory should not be written to by the user.
6. Finally, the OS binds `/mnt/journal` to `/var/log/journal` to enable persistent journal archiving, see [var-log-journal.mount](overlay/usr/lib/systemd/system/var-log-journal.mount).

Emergency fallback handling:
1. If something malfunctions and the read-write FSW (`/root/bus` folder) is not accessible after boot, the EXT4 filesystem will be re-generated automatically using the [fs-initialize.service](overlay/usr/lib/systemd/system/fs-initialize.service). This will restore the system to the golden image state.
2. If even the EXT4 filesystem generation fails for some reason, the OS will bind `/usr/local/fsw` directly to `/root`, see [fs-fallback.service](overlay/usr/lib/systemd/system/fs-fallback.service). This will allow the system to operate at least in a read-only mode using the golden image software.

## Journal archiving
If the EXT4 filesystem is operational, journal logs from each boot are archived in `/mnt/journal`. Systemd creates a folder with the name of the current boot ID that contains the system and user logs.

To help identify which ID is from which boot (since we don't know the time during boot), [id-save.service](overlay/usr/lib/systemd/system/id-save.service) appends the current ID to `/mnt/journal/id.txt` on each boot.

The logs can then be viewed on ground or through SSH via `journalctl --file <boot_id>/system.journal`.

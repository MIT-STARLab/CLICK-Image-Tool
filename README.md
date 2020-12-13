# CLICK Image Tool
Tool to generate the golden image to be flashed on the Raspberry Pi. It cross-compiles a cut-down Linux with a few packages using [buildroot](https://buildroot.org/).

## Overview
- `build.sh`: the main script that executes buildroot. Has a variable `CLICK_FSW_VERSION` defining which flight software version to bundle, and `BOOT_WITH_PPP` which can be used to generate an image that boots in debugging mode with PPP/SSH running.
- `config_buildroot.txt`: buildroot config flags. Defines how to build the system, which Linux kernel git commit to use (`BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION`), which packages to include in the system (`BR2_PACKAGE_xxx`), and some other basic configuration. Can be modified to add more software packages if needed.
- `config_kernel.txt`: Linux kernel config flags. Defines which kernel modules are bundled with the kernel image and which are built as external modules. Mostly disables a lot of unneeded kernel features and drivers to make the image smaller. Should not need changing.
- `config_rpi.txt`: config for the RPi bootloader. Sets a static GPU clock to fix SPI frequency and configures the SPI using the device tree overlay from the SPI driver.
- `rpi_cmdline.txt`: variables passed by the bootloader to the kernel on boot, such as the primary partition etc.
- `extra/`: definitions for custom/uncommon packages that are not included in buildroot by default, such as the custom flight software and the png2jpeg tool. Each folder in `extra/package` has makefiles that define how the package is downloaded, built and installed to the image. More uncommon software packages can be defined here.
- `overlay/`: custom tree of files that are added directly to the OS partition by buildroot. These include some system config files, OS services, and the Matrix Vision and FPGAlink libraries.
- `post_build.sh`: script that is automatically executed after buldroot is done with all package compilation. It does some OS configuration before it is packaged.
- `post_image.sh`: script that is automatically executed after buldroot packages the OS. It creates a raw flash image with all the partitions, which can be directly flashed onto the RPi eMMC.

## Partitions
The final image (~17 MB) contains three partitions:
1. boot (~3 MB): a FAT-16 filesystem with the bootloader files and the (compressed) kernel image.
2. OS (~14 MB): a [SquashFS](https://en.wikipedia.org/wiki/SquashFS) compressed read-only filesystem that contains all the other OS files and packages, including the "golden" CLICK flight software files.
3. RW (3.7 GB): an empty EXT4 read-write filesystem that is created on first boot. The image only contains its partition table entry, not any data.

## Filesystem handling
The way the OS handles the filesystems is explained below:
1. The OS is configured to only use the root user account.
2. The original root user files, including the golden CLICK FSW, are stored read-only at /usr/local/fsw.
3. On first boot, the read-write EXT4 partition is created and mounted on /mnt, see `overlay/usr/lib/systemd/system/fs-initialize.service`.
4. Next, an [overlay filesystem](https://wiki.archlinux.org/index.php/Overlay_filesystem) is automatically mounted on /root. The overlay filesystem will mirror all the read-only files from /usr/local/fsw, but allow overwriting them within /root. However, all the changes are actually kept behind the scenes on /mnt/overlay (this is invisible to the user). This allows making changes to the original root user files and the CLICK FSW without needing changes on the read-only filesystem.
5. If the EXT4 filesystem malfunctions and /mnt/overlay is not accessible, the filesystem will be re-generated using the `fs-initialize.service` on boot. This will restore the system to the golden image state.
6. If even the EXT4 filesystem generation fails for some reason, the OS will bind /usr/local/fsw directly to /root, see `overlay/usr/lib/systemd/system/fs-fallback.service`. This will allow the system to operate at least in a read-only mode using the golden image software.

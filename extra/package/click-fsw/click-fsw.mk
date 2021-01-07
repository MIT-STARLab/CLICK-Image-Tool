# Defines how to install custom CLICK flight software
# FSW_VERSION is defined in build.sh
CLICK_FSW_VERSION = $(FSW_VERSION)
CLICK_FSW_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,$(FSW_VERSION))
CLICK_FSW_LICENSE = LGPL-3.0
CLICK_FSW_LICENSE_FILES = LICENSE.md
CLICK_FSW_DEPENDENCIES = cppzmq matrix-vision
CLICK_FSW_INSTALL_IMAGES = YES

# Force kernel to export the needed symbols for the kernel SPI driver (./bus/driver)
# By default, the kernel build is configured to strip unused symbols to save space
# The symbols.txt file can be generated using "make symbols" with the SPI driver Makefie (when built outside of buildroot)
KVERSION = $(LINUX_VERSION_PROBED)
KSYMS = "$(BR2_EXTERNAL_CLICK_PATH)/package/click-fsw/symbols.txt"
CLICK_FSW_LINUX_CONFIG_FIXUPS = $(call KCONFIG_SET_OPT,CONFIG_UNUSED_KSYMS_WHITELIST,$(KSYMS))
CLICK_FSW_MODULE_SUBDIRS = bus/driver

# Compile the SPI driver
$(eval $(kernel-module))

# Compile PAT and testers
define CLICK_FSW_BUILD_CMDS
    $(MAKE) $(TARGET_CONFIGURE_OPTS) CXXFLAGS="-Os -D_REENTRANT -Wno-psabi -Wno-deprecated-declarations \
        -Wl,-unresolved-symbols=ignore-in-shared-libs -fPIC -pedantic" -C $(@D)/camera/pat all enumerate
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/bus/driver test
    $(MAKE) $(TARGET_CONFIGURE_OPTS) LIBDIRS=-L$(BR2_EXTERNAL_CLICK_PATH)/../overlay/usr/lib -C $(@D)/fpga/fline
endef

# Install the flight software
define CLICK_FSW_INSTALL_TARGET_CMDS
    # Install PAT and testers
    $(INSTALL) -d $(TARGET_DIR)/usr/local/fsw/bin
    $(INSTALL) -m 0755 $(@D)/camera/pat/pat $(TARGET_DIR)/usr/local/fsw/bin
    $(INSTALL) -m 0755 $(@D)/camera/pat/enumerate $(TARGET_DIR)/usr/local/fsw/bin/test_camera
    $(INSTALL) -m 0755 $(@D)/bus/driver/test_tlm $(TARGET_DIR)/usr/local/fsw/bin
    $(INSTALL) -m 0755 $(@D)/fpga/fline/fline $(TARGET_DIR)/usr/local/fsw/bin
    
    # Rsync all non-binary files
    rsync -a --exclude='.*' --exclude='*.md' --exclude='*~' --exclude='*.o' \
        --exclude='camera' --exclude='services' --exclude='bus/driver' --exclude='fpga/fline' \
        $(@D)/ $(TARGET_DIR)/usr/local/fsw/
    
    # Install FSW systemd user services
    ln -sfn .config/systemd/user ${TARGET_DIR}/usr/local/fsw/services
    $(INSTALL) -d ${TARGET_DIR}/usr/local/fsw/.config/systemd/user/default.target.wants
    $(INSTALL) -m 0644 $(@D)/services/* ${TARGET_DIR}/usr/local/fsw/.config/systemd/user
    for svc in $(notdir $(wildcard $(@D)/services/*)); do \
        grep -qE '^WantedBy=default' $(@D)/services/$$svc && ln -sfn ../$$svc \
        ${TARGET_DIR}/usr/local/fsw/.config/systemd/user/default.target.wants/$$svc; \
    done
endef

# Install SPI device tree overlay
define CLICK_FSW_INSTALL_IMAGES_CMDS 
    mkdir -p ${BINARIES_DIR}/overlays
    dtc -O dtb -o ${BINARIES_DIR}/overlays/click_spi.dtbo -b 0 -@ $(@D)/bus/driver/click_spi.dts
endef

# Post install hook
define CLICK_FSW_POST_INSTALL
    # Install SPI kernel driver to /usr/local/fsw/bin
    mv $(TARGET_DIR)/lib/modules/$(KVERSION)/extra/click_spi.ko \
        $(TARGET_DIR)/usr/local/fsw/bin

    # Save binaries to top-level /bin folder for uplink
    cp -r $(TARGET_DIR)/usr/local/fsw/bin $(BASE_DIR)/../
endef

CLICK_FSW_POST_INSTALL_TARGET_HOOKS += CLICK_FSW_POST_INSTALL

$(eval $(generic-package))

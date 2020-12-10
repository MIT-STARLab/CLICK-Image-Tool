################################################################################
#
# imagemagick custom makefile
#
################################################################################

IMAGE_CONVERT_VERSION = 7.0.10-28
IMAGE_CONVERT_SITE = $(call github,ImageMagick,ImageMagick,$(IMAGE_CONVERT_VERSION))
IMAGE_CONVERT_LICENSE = Apache-2.0
IMAGE_CONVERT_LICENSE_FILES = LICENSE

IMAGE_CONVERT_INSTALL_STAGING = YES

IMAGE_CONVERT_CONF_ENV = \
	ac_cv_sys_file_offset_bits=64 \
	ax_cv_check_cl_libcl=no

IMAGE_CONVERT_CONF_OPTS = \
	--program-transform-name='s,,,' \
	--disable-opencl \
	--disable-openmp \
	--disable-largefile \
	--disable-hdri \
	--with-jpeg \
	--with-png \
	--with-zlib \
	--without-djvu \
	--without-dps \
	--without-flif \
	--without-fpx \
	--without-gslib \
	--without-gvc \
	--without-jbig \
	--without-lqr \
	--without-openexr \
	--without-perl \
	--without-raqm \
	--without-wmf \
	--without-fontconfig \
	--without-freetype \
	--without-lcms \
	--without-rsvg \
	--without-x \
	--without-xml \
	--without-pango \
	--without-tiff \
	--without-lzma \
	--without-fftw \
	--without-webp \
	--without-bzlib \
	--without-magick-plus-plus \
	--with-gs-font-dir=/usr/share/fonts/gs

IMAGE_CONVERT_DEPENDENCIES = host-pkgconf jpeg libpng

$(eval $(autotools-package))

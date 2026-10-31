#!/usr/bin/env bash

EXTRA_LIBASS_FLAGS=""
case $ANDROID_ABI in
  x86)
    EXTRA_LIBASS_FLAGS="--disable-asm"
    ;;
  x86_64)
    EXTRA_LIBASS_FLAGS="--enable-asm"
    ;;
  armeabi-v7a)
    EXTRA_LIBASS_FLAGS="--enable-asm"
    ;;
  arm64-v8a)
    EXTRA_LIBASS_FLAGS="--enable-asm"
    ;;
esac

./configure \
    --prefix=${INSTALL_DIR} \
    --host=${TARGET} \
    --with-sysroot=${SYSROOT_PATH} \
    --disable-shared \
    --enable-static \
    --disable-fontconfig \
    --disable-require-system-font-provider \
    --disable-harfbuzz \
    --with-pic \
    ${EXTRA_LIBASS_FLAGS} \
    CC=${FAM_CC} \
    AR=${FAM_AR} \
    RANLIB=${FAM_RANLIB} \
    PKG_CONFIG=${PKG_CONFIG_EXECUTABLE} || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install

#!/usr/bin/env bash

CFLAGS=
if [ "$ANDROID_ABI" = "x86" ] ; then
    CFLAGS="-mtune="
fi

./configure \
    --prefix=${INSTALL_DIR} \
    --host=${TARGET} \
    --with-sysroot=${SYSROOT_PATH} \
    --disable-shared \
    --enable-static \
    --with-pic \
    --disable-fast-install \
    --disable-analyzer-hooks \
    --disable-gtktest \
    --disable-frontend \
    CFLAGS=$CFLAGS \
    CC=${FAM_CC} \
    AR=${FAM_AR} \
    RANLIB=${FAM_RANLIB} || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install

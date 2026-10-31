#!/usr/bin/env bash

./configure \
    --prefix=${INSTALL_DIR} \
    --host=${TARGET} \
    --with-sysroot=${SYSROOT_PATH} \
    --disable-shared \
    --enable-static \
    --disable-dependency-tracking \
    --disable-fast-install \
    --disable-debug \
    --disable-deprecated \
    --with-pic \
    CC=${FAM_CC} \
    AR=${FAM_AR} \
    RANLIB=${FAM_RANLIB} || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC} -C lib
${MAKE_EXECUTABLE} install -C lib
${MAKE_EXECUTABLE} install-data-am

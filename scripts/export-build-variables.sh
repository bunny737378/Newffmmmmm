#!/usr/bin/env bash

function max() {
  local a=${1:-21}
  local b=${2:-21}
  [ "$a" -ge "$b" ] && echo "$a" || echo "$b"
}

export ANDROID_ABI=$1

if [ $ANDROID_ABI = "arm64-v8a" ] || [ $ANDROID_ABI = "x86_64" ] ; then
  export ANDROID_PLATFORM=$(max ${DESIRED_ANDROID_API_LEVEL} 21)
else
  export ANDROID_PLATFORM=${DESIRED_ANDROID_API_LEVEL}
fi

export TOOLCHAIN_PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}
export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot

TARGET_TRIPLE_MACHINE_CC=
CPU_FAMILY=
export TARGET_TRIPLE_OS="android"

case $ANDROID_ABI in
  armeabi-v7a)
    export TARGET_TRIPLE_MACHINE_ARCH=arm
    TARGET_TRIPLE_MACHINE_CC=armv7a
    export TARGET_TRIPLE_OS=androideabi
    ;;
  arm64-v8a)
    export TARGET_TRIPLE_MACHINE_ARCH=aarch64
    ;;
  x86)
    export TARGET_TRIPLE_MACHINE_ARCH=i686
    CPU_FAMILY=x86
    ;;
  x86_64)
    export TARGET_TRIPLE_MACHINE_ARCH=x86_64
    ;;
esac

[ -z "${TARGET_TRIPLE_MACHINE_CC}" ] && TARGET_TRIPLE_MACHINE_CC=${TARGET_TRIPLE_MACHINE_ARCH}

[ -z "${CPU_FAMILY}" ] && CPU_FAMILY=${TARGET_TRIPLE_MACHINE_ARCH}
export CPU_FAMILY=$CPU_FAMILY

export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/llvm-

export FAM_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export        FAM_AR=${CROSS_PREFIX_WITH_PATH}ar
export        FAM_AS=${CROSS_PREFIX_WITH_PATH}as
export        FAM_NM=${CROSS_PREFIX_WITH_PATH}nm
export   FAM_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export   FAM_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export    FAM_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export   FAM_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export      FAM_SIZE=${CROSS_PREFIX_WITH_PATH}size
export   FAM_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export     FAM_STRIP=${CROSS_PREFIX_WITH_PATH}strip

export TARGET=${TARGET_TRIPLE_MACHINE_CC}-linux-${TARGET_TRIPLE_OS}${ANDROID_PLATFORM}
export FAM_CC=${TOOLCHAIN_PATH}/bin/${TARGET}-clang
export FAM_CXX=${FAM_CC}++
export FAM_LD=${FAM_CC}

export FAM_YASM=${TOOLCHAIN_PATH}/bin/yasm

export FFMPEG_EXTRA_LD_FLAGS=

export EXTRA_BUILD_CONFIGURATION_FLAGS=

export INSTALL_DIR=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}

export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig
export PKG_CONFIG_PATH=${PKG_CONFIG_LIBDIR}

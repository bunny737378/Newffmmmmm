#!/usr/bin/env bash

if [[ -z "${ANDROID_SDK_HOME}" ]]; then
  if [[ -n "${ANDROID_SDK_ROOT}" ]]; then
    export ANDROID_SDK_HOME="${ANDROID_SDK_ROOT}"
  elif [[ -n "${ANDROID_HOME}" ]]; then
    export ANDROID_SDK_HOME="${ANDROID_HOME}"
  fi
fi

if [[ -z "${ANDROID_NDK_HOME}" ]]; then
  if [[ -n "${ANDROID_SDK_HOME}" && -d "${ANDROID_SDK_HOME}/ndk" ]]; then
    LATEST_NDK=$(ls -1 "${ANDROID_SDK_HOME}/ndk" 2>/dev/null | sort -V | tail -n 1)
    if [[ -n "${LATEST_NDK}" ]]; then
      export ANDROID_NDK_HOME="${ANDROID_SDK_HOME}/ndk/${LATEST_NDK}"
    fi
  elif [[ -n "${NDK_HOME}" ]]; then
    export ANDROID_NDK_HOME="${NDK_HOME}"
  elif [[ -n "${NDK}" ]]; then
    export ANDROID_NDK_HOME="${NDK}"
  fi
fi

case "$OSTYPE" in
  darwin*)  HOST_TAG="darwin-x86_64" ;;
  linux*)   HOST_TAG="linux-x86_64" ;;
  msys)
    case "$(uname -m)" in
      x86_64) HOST_TAG="windows-x86_64" ;;
      i686)   HOST_TAG="windows" ;;
    esac
  ;;
esac

if [[ $OSTYPE == "darwin"* ]]; then
  HOST_NPROC=$(sysctl -n hw.physicalcpu)
else
  HOST_NPROC=$(nproc 2>/dev/null || echo 4)
fi

export HOST_TAG=$HOST_TAG
export HOST_NPROC=$HOST_NPROC

export CMAKE_EXECUTABLE=$(which cmake 2>/dev/null || command -v cmake 2>/dev/null || echo "cmake")

if [[ -n "${ANDROID_NDK_HOME}" && -x "${ANDROID_NDK_HOME}/prebuilt/${HOST_TAG}/bin/make" ]]; then
  export MAKE_EXECUTABLE=${ANDROID_NDK_HOME}/prebuilt/${HOST_TAG}/bin/make
else
  export MAKE_EXECUTABLE=$(which make 2>/dev/null || command -v make 2>/dev/null || echo "make")
fi

export NINJA_EXECUTABLE=$(which ninja 2>/dev/null || command -v ninja 2>/dev/null || echo "ninja")

export MESON_EXECUTABLE=$(which meson 2>/dev/null || command -v meson 2>/dev/null || echo "meson")

export NASM_EXECUTABLE=$(which nasm 2>/dev/null || command -v nasm 2>/dev/null || echo "nasm")

export PKG_CONFIG_EXECUTABLE=$(which pkg-config 2>/dev/null || command -v pkg-config 2>/dev/null || which pkgconf 2>/dev/null || command -v pkgconf 2>/dev/null || echo "pkg-config")

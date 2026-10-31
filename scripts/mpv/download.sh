#!/usr/bin/env bash

MPV_VERSION=0.41.0
MPV_TARBALL="mpv-${MPV_VERSION}.tar.gz"
MPV_URL="https://github.com/mpv-player/mpv/archive/refs/tags/v${MPV_VERSION}.tar.gz"

SOURCE_DIR_FOR_MPV=${SOURCES_DIR}/mpv/mpv-${MPV_VERSION}

if [ ! -d "${SOURCE_DIR_FOR_MPV}" ] || [ ! -f "${SOURCE_DIR_FOR_MPV}/meson.build" ]; then
  mkdir -p "${SOURCES_DIR}/mpv"
  pushd "${SOURCES_DIR}/mpv" > /dev/null
  echo "Downloading mpv ${MPV_VERSION}..."
  curl -sL "${MPV_URL}" -o "${MPV_TARBALL}"
  mkdir -p "${SOURCE_DIR_FOR_MPV}"
  tar -xzf "${MPV_TARBALL}" --strip-components=1 -C "${SOURCE_DIR_FOR_MPV}"
  rm -f "${MPV_TARBALL}"
  popd > /dev/null
fi

export SOURCES_DIR_mpv=${SOURCE_DIR_FOR_MPV}

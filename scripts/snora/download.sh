#!/usr/bin/env bash

ENGINE_VERSION=0.41.0
ENGINE_TARBALL="snora-engine-${ENGINE_VERSION}.tar.gz"
ENGINE_URL="https://github.com/mpv-player/mpv/archive/refs/tags/v${ENGINE_VERSION}.tar.gz"

SOURCE_DIR_FOR_SNORA=${SOURCES_DIR}/snora/engine-${ENGINE_VERSION}

if [ ! -d "${SOURCE_DIR_FOR_SNORA}" ] || [ ! -f "${SOURCE_DIR_FOR_SNORA}/meson.build" ]; then
  mkdir -p "${SOURCES_DIR}/snora"
  pushd "${SOURCES_DIR}/snora" > /dev/null
  echo "Downloading Snora engine sources (${ENGINE_VERSION})..."
  curl -sL "${ENGINE_URL}" -o "${ENGINE_TARBALL}"
  mkdir -p "${SOURCE_DIR_FOR_SNORA}"
  tar -xzf "${ENGINE_TARBALL}" --strip-components=1 -C "${SOURCE_DIR_FOR_SNORA}"
  rm -f "${ENGINE_TARBALL}"
  popd > /dev/null
fi

export SOURCES_DIR_snora=${SOURCE_DIR_FOR_SNORA}

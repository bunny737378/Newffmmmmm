#!/usr/bin/env bash

PLACEBO_VERSION=6.338.2
PLACEBO_TARBALL="libplacebo-${PLACEBO_VERSION}.tar.gz"
PLACEBO_URL="https://github.com/haasn/libplacebo/archive/refs/tags/v${PLACEBO_VERSION}.tar.gz"
SOURCE_DIR_FOR_LIBPLACEBO=${SOURCES_DIR}/libplacebo/libplacebo-${PLACEBO_VERSION}

if [ ! -d "${SOURCE_DIR_FOR_LIBPLACEBO}" ] || [ ! -f "${SOURCE_DIR_FOR_LIBPLACEBO}/meson.build" ]; then
  mkdir -p "${SOURCES_DIR}/libplacebo"
  pushd "${SOURCES_DIR}/libplacebo" > /dev/null
  echo "Downloading libplacebo ${PLACEBO_VERSION}..."
  curl -sL "${PLACEBO_URL}" -o "${PLACEBO_TARBALL}"
  mkdir -p "${SOURCE_DIR_FOR_LIBPLACEBO}"
  tar -xzf "${PLACEBO_TARBALL}" --strip-components=1 -C "${SOURCE_DIR_FOR_LIBPLACEBO}"
  rm -f "${PLACEBO_TARBALL}"

  # Fetch fast_float 3rdparty dependency required by libplacebo
  mkdir -p "${SOURCE_DIR_FOR_LIBPLACEBO}/3rdparty/fast_float"
  curl -sL https://github.com/fastfloat/fast_float/archive/refs/tags/v6.1.0.tar.gz | tar -xz --strip-components=1 -C "${SOURCE_DIR_FOR_LIBPLACEBO}/3rdparty/fast_float"
  popd > /dev/null
fi

export SOURCES_DIR_libplacebo=${SOURCE_DIR_FOR_LIBPLACEBO}

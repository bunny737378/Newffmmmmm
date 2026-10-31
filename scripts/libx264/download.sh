#!/usr/bin/env bash

source ${SCRIPTS_DIR}/common-functions.sh

LIBX264_VERSION=b35605ace3ddf7c1a5d67a2eb553f034aef41d55

downloadTarArchive \
  "libx264" \
  "https://code.videolan.org/videolan/x264/-/archive/${LIBX264_VERSION}/x264-${LIBX264_VERSION}.tar.gz"

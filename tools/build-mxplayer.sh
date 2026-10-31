#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"

echo "=========================================================="
echo " Starting FFmpeg Compilation (MX Player Ultimate Profile)"
echo "=========================================================="

"${BASE_DIR}/ffmpeg-android-maker.sh" --profile=mxplayer "$@"

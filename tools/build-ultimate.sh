#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"

echo "=========================================================="
echo " Starting FFmpeg Compilation (Ultimate Universal Profile)"
echo "=========================================================="

"${BASE_DIR}/ffmpeg-android-maker.sh" --profile=ultimate "$@"

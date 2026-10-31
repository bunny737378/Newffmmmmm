#!/usr/bin/env bash

ABIS_TO_BUILD=()
API_LEVEL=21
SOURCE_TYPE=TAR
SOURCE_VALUE=8.1.2
EXTERNAL_LIBRARIES=()
FFMPEG_GPL_ENABLED=false
ENABLE_MEDIACODEC=false
BUILD_SINGLE_SO=false
ULTIMATE_PROFILE=false
USE_PREBUILT_FFMPEG=false

SUPPORTED_LIBRARIES_FREE=(
  "libaom"
  "libdav1d"
  "libmp3lame"
  "libopus"
  "libtwolame"
  "libspeex"
  "libvpx"
  "libwebp"
  "libfreetype"
  "libfribidi"
  "libass"
  "mbedtls"
  "libbluray"
  "libxml2"
)

SUPPORTED_LIBRARIES_GPL=(
  "libx264"
  "libx265"
)

for argument in "$@"; do
  case $argument in
  --profile=ultimate | --profile=full | --ultimate | -u | --all-codecs | --profile=mxplayer | --mxplayer | -mx)
    ULTIMATE_PROFILE=true
    ENABLE_MEDIACODEC=true
    FFMPEG_GPL_ENABLED=true
    EXTERNAL_LIBRARIES+=("${SUPPORTED_LIBRARIES_FREE[@]}")
    EXTERNAL_LIBRARIES+=("${SUPPORTED_LIBRARIES_GPL[@]}")
    ;;
  --target-abis=* | -abis=*)
    IFS=',' read -ra ABIS <<<"${argument#*=}"
    for abi in "${ABIS[@]}"; do
      case $abi in
      x86 | x86_64 | armeabi-v7a | arm64-v8a)
        ABIS_TO_BUILD+=("$abi")
        ;;
      arm)
        ABIS_TO_BUILD+=("armeabi-v7a")
        ;;
      arm64)
        ABIS_TO_BUILD+=("arm64-v8a")
        ;;
      *)
        echo "Unknown ABI: $abi"
        ;;
      esac
    done
    ;;
  --android-api-level=* | -android=*)
    API_LEVEL="${argument#*=}"
    ;;
  --source-git-tag=*)
    SOURCE_TYPE=GIT_TAG
    SOURCE_VALUE="${argument#*=}"
    ;;
  --source-git-branch=*)
    SOURCE_TYPE=GIT_BRANCH
    SOURCE_VALUE="${argument#*=}"
    ;;
  --source-tar=*)
    SOURCE_TYPE=TAR
    SOURCE_VALUE="${argument#*=}"
    ;;
  --enable-libass | -ass)
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libfreetype " ]] && EXTERNAL_LIBRARIES+=("libfreetype")
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libfribidi " ]] && EXTERNAL_LIBRARIES+=("libfribidi")
    EXTERNAL_LIBRARIES+=("libass")
    ;;
  --enable-mediacodec | -mediacodec)
    ENABLE_MEDIACODEC=true
    ;;
  --build-single-so | -single-so)
    BUILD_SINGLE_SO=true
    ;;
  --build-mx-so | -mx-so)
    BUILD_SINGLE_SO=true
    BUILD_MX_SO=true
    ;;
  --package-aio | -aio)
    PACKAGE_AIO=true
    ;;
  --enable-libaom | -aom)
    EXTERNAL_LIBRARIES+=("libaom")
    ;;
  --enable-libdav1d | -dav1d)
    EXTERNAL_LIBRARIES+=("libdav1d")
    ;;
  --enable-libmp3lame | -mp3lame | -lame)
    EXTERNAL_LIBRARIES+=("libmp3lame")
    ;;
  --enable-libopus | -opus)
    EXTERNAL_LIBRARIES+=("libopus")
    ;;
  --enable-libwebp | -webp)
    EXTERNAL_LIBRARIES+=("libwebp")
    ;;
  --enable-libtwolame | -twolame)
    EXTERNAL_LIBRARIES+=("libtwolame")
    ;;
  --enable-libspeex | -speex)
    EXTERNAL_LIBRARIES+=("libspeex")
    ;;
  --enable-libvpx | -vpx)
    EXTERNAL_LIBRARIES+=("libvpx")
    ;;
  --enable-libfreetype | -freetype)
    EXTERNAL_LIBRARIES+=("libfreetype")
    ;;
  --enable-libfribidi | -fribidi)
    EXTERNAL_LIBRARIES+=("libfribidi")
    ;;
  --enable-libx264 | -x264)
    EXTERNAL_LIBRARIES+=("libx264")
    FFMPEG_GPL_ENABLED=true
    ;;
  --enable-libx265 | -x265)
    EXTERNAL_LIBRARIES+=("libx265")
    FFMPEG_GPL_ENABLED=true
    ;;
  --enable-mbedtls | -mbedtls)
    EXTERNAL_LIBRARIES+=("mbedtls")
    ;;
  --enable-libbluray | -bluray)
    EXTERNAL_LIBRARIES+=("libbluray")
    ;; 
  --enable-libxml2 | -xml2)
    EXTERNAL_LIBRARIES+=("libxml2")
    ;;
  --use-prebuilt-ffmpeg | --skip-ffmpeg)
    USE_PREBUILT_FFMPEG=true
    ;;
  --enable-libplacebo | -placebo)
    EXTERNAL_LIBRARIES+=("libplacebo")
    ;;
  --enable-mpv | -mpv)
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libfreetype " ]] && EXTERNAL_LIBRARIES+=("libfreetype")
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libfribidi " ]] && EXTERNAL_LIBRARIES+=("libfribidi")
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libass " ]] && EXTERNAL_LIBRARIES+=("libass")
    [[ ! " ${EXTERNAL_LIBRARIES[@]} " =~ " libplacebo " ]] && EXTERNAL_LIBRARIES+=("libplacebo")
    EXTERNAL_LIBRARIES+=("mpv")
    ;;
  --enable-all-free | -all-free)
    EXTERNAL_LIBRARIES+=("${SUPPORTED_LIBRARIES_FREE[@]}")
    ;;
  --enable-all-gpl | -all-gpl)
    EXTERNAL_LIBRARIES+=("${SUPPORTED_LIBRARIES_GPL[@]}")
    FFMPEG_GPL_ENABLED=true
    ;;
  *)
    echo "Unknown argument $argument"
    ;;
  esac
  shift
done

DEDUPED_LIBRARIES=()
for lib in "${EXTERNAL_LIBRARIES[@]}"; do
  [[ ! " ${DEDUPED_LIBRARIES[@]} " =~ " ${lib} " ]] && DEDUPED_LIBRARIES+=("${lib}")
done
EXTERNAL_LIBRARIES=("${DEDUPED_LIBRARIES[@]}")

if [ ${#ABIS_TO_BUILD[@]} -eq 0 ]; then
  ABIS_TO_BUILD=("x86" "x86_64" "armeabi-v7a" "arm64-v8a")
fi

export FFMPEG_ABIS_TO_BUILD=${ABIS_TO_BUILD[@]}

export FFMPEG_SOURCE_TYPE=$SOURCE_TYPE
export FFMPEG_SOURCE_VALUE=$SOURCE_VALUE

export FFMPEG_EXTERNAL_LIBRARIES=${EXTERNAL_LIBRARIES[@]}

export DESIRED_ANDROID_API_LEVEL=${API_LEVEL}

export FFMPEG_GPL_ENABLED=$FFMPEG_GPL_ENABLED
export ENABLE_MEDIACODEC=$ENABLE_MEDIACODEC
export BUILD_SINGLE_SO=$BUILD_SINGLE_SO
export BUILD_MX_SO=$BUILD_MX_SO
export PACKAGE_AIO=$PACKAGE_AIO
export ULTIMATE_PROFILE=$ULTIMATE_PROFILE
export MX_PROFILE=$MX_PROFILE
export USE_PREBUILT_FFMPEG=$USE_PREBUILT_FFMPEG

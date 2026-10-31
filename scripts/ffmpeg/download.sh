#!/usr/bin/env bash

function ensureSourcesTar() {
  source ${SCRIPTS_DIR}/common-functions.sh

  FFMPEG_TAR_DIR="ffmpeg-${FFMPEG_SOURCE_VALUE}"
  if [[ ! -d "$FFMPEG_TAR_DIR" && ! -d "FFmpeg-n${FFMPEG_SOURCE_VALUE}" ]]; then
    if curl -sSfL "https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${FFMPEG_SOURCE_VALUE}.tar.gz" -o "ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.gz" 2>/dev/null; then
      tar xf "ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.gz" || python3 -c "import tarfile, sys; tarfile.open(sys.argv[1]).extractall(sys.argv[2])" "ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.gz" "."
      rm -f "ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.gz"
      if [[ -d "FFmpeg-n${FFMPEG_SOURCE_VALUE}" ]]; then
        mv "FFmpeg-n${FFMPEG_SOURCE_VALUE}" "$FFMPEG_TAR_DIR"
      fi
    else
      downloadTarArchive \
        "ffmpeg" \
        "https://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.bz2"
    fi
  fi

  if [[ -d "$FFMPEG_TAR_DIR" ]]; then
    export SOURCES_DIR_ffmpeg=$(pwd)/${FFMPEG_TAR_DIR}
  elif [[ -d "FFmpeg-n${FFMPEG_SOURCE_VALUE}" ]]; then
    export SOURCES_DIR_ffmpeg=$(pwd)/FFmpeg-n${FFMPEG_SOURCE_VALUE}
  fi
}

function ensureSourcesGit() {
  NAME_TO_CHECKOUT=${FFMPEG_SOURCE_VALUE}

  GIT_DIRECTORY=ffmpeg-git

  FFMPEG_SOURCES=$(pwd)/${GIT_DIRECTORY}

  if [[ ! -d "$FFMPEG_SOURCES" ]]; then
    git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git ${GIT_DIRECTORY} || \
    git clone https://git.ffmpeg.org/ffmpeg.git ${GIT_DIRECTORY}
  fi

  cd ${GIT_DIRECTORY}
  git reset --hard

  git checkout $NAME_TO_CHECKOUT 2>/dev/null || git checkout "n${NAME_TO_CHECKOUT}" 2>/dev/null || true
  if [ ${FFMPEG_SOURCE_TYPE} = "GIT_BRANCH" ]; then
    git pull origin $BRANCH
  fi

  echo "Commit to build:"
  git rev-parse HEAD

  export SOURCES_DIR_ffmpeg=${FFMPEG_SOURCES}
}

case ${FFMPEG_SOURCE_TYPE} in
  GIT_TAG)
    echo "Using FFmpeg git tag: ${FFMPEG_SOURCE_VALUE}"
    ensureSourcesGit
    ;;
  GIT_BRANCH)
    echo "Using FFmpeg git branch: ${FFMPEG_SOURCE_VALUE}"
    ensureSourcesGit
    ;;
  TAR)
    echo "Using FFmpeg source archive: ${FFMPEG_SOURCE_VALUE}"
    ensureSourcesTar
    ;;
  *)
    echo "Unknown source type: ${FFMPEG_SOURCE_TYPE}"
    exit 1
    ;;
esac

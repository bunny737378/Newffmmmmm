#!/usr/bin/env bash

export BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
export SOURCES_DIR=${BASE_DIR}/sources
export STATS_DIR=${BASE_DIR}/stats
export SCRIPTS_DIR=${BASE_DIR}/scripts
export OUTPUT_DIR=${BASE_DIR}/output

source ${SCRIPTS_DIR}/check-host-machine.sh || exit 1

BUILD_DIR=${BASE_DIR}/build
export BUILD_DIR_FFMPEG=$BUILD_DIR/ffmpeg
export BUILD_DIR_EXTERNAL=$BUILD_DIR/external

function prepareOutput() {
  OUTPUT_LIB=${OUTPUT_DIR}/lib/${ANDROID_ABI}
  mkdir -p ${OUTPUT_LIB}
  if [ -d "${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib" ]; then
    cp -a ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib/*.so ${OUTPUT_LIB} 2>/dev/null || true
  fi
  if [ -d "${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib" ]; then
    cp -a ${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib/*.so ${OUTPUT_LIB} 2>/dev/null || true
  fi

  OUTPUT_HEADERS=${OUTPUT_DIR}/include/${ANDROID_ABI}
  mkdir -p ${OUTPUT_HEADERS}
  if [ -d "${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/include" ]; then
    cp -r ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/include/* ${OUTPUT_HEADERS} 2>/dev/null || true
  fi
  if [ -d "${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include" ]; then
    cp -r ${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include/* ${OUTPUT_HEADERS} 2>/dev/null || true
  fi

  if [ -d "${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/bin" ]; then
    OUTPUT_BIN=${OUTPUT_DIR}/bin/${ANDROID_ABI}
    mkdir -p ${OUTPUT_BIN}
    cp -r ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/bin/* ${OUTPUT_BIN} 2>/dev/null || true
  fi
}

function checkTextRelocations() {
  TEXT_REL_STATS_FILE=${STATS_DIR}/text-relocations.txt
  ${FAM_READELF} --dynamic ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib/*.so | grep 'TEXTREL\|File' >> ${TEXT_REL_STATS_FILE}

  if grep -q TEXTREL ${TEXT_REL_STATS_FILE}; then
    echo "There are text relocations in output files:"
    cat ${TEXT_REL_STATS_FILE}
    exit 1
  fi
}

source ${SCRIPTS_DIR}/export-host-variables.sh
source ${SCRIPTS_DIR}/parse-arguments.sh

if [ "$USE_PREBUILT_FFMPEG" = true ]; then
  echo "==> Using prebuilt FFmpeg. Skipping FFmpeg compilation."
  rm -rf ${BUILD_DIR_EXTERNAL}
  rm -rf ${STATS_DIR}
  rm -rf ${OUTPUT_DIR}
else
  rm -rf ${BUILD_DIR}
  rm -rf ${STATS_DIR}
  rm -rf ${OUTPUT_DIR}
fi
mkdir -p ${STATS_DIR}
mkdir -p ${OUTPUT_DIR}

if [ "$USE_PREBUILT_FFMPEG" = true ]; then
  COMPONENTS_TO_BUILD=()
  for lib in "${EXTERNAL_LIBRARIES[@]}"; do
    COMPONENTS_TO_BUILD+=("$lib")
  done
else
  BEFORE_FFMPEG=()
  HAS_MPV=false
  for lib in "${EXTERNAL_LIBRARIES[@]}"; do
    if [ "$lib" == "mpv" ]; then
      HAS_MPV=true
    else
      BEFORE_FFMPEG+=("$lib")
    fi
  done

  COMPONENTS_TO_BUILD=("${BEFORE_FFMPEG[@]}" "ffmpeg")
  if [ "$HAS_MPV" = true ]; then
    COMPONENTS_TO_BUILD+=("mpv")
  fi
fi

for COMPONENT in ${COMPONENTS_TO_BUILD[@]}
do
  echo "Getting source code of the component: ${COMPONENT}"
  SOURCE_DIR_FOR_COMPONENT=${SOURCES_DIR}/${COMPONENT}

  mkdir -p ${SOURCE_DIR_FOR_COMPONENT}
  cd ${SOURCE_DIR_FOR_COMPONENT}

  source ${SCRIPTS_DIR}/${COMPONENT}/download.sh

  COMPONENT_SOURCES_DIR_VARIABLE=SOURCES_DIR_${COMPONENT}
  if [[ -z "${!COMPONENT_SOURCES_DIR_VARIABLE}" ]]; then
     export SOURCES_DIR_${COMPONENT}=${SOURCE_DIR_FOR_COMPONENT}
  fi

  cd ${BASE_DIR}
done

for ABI in ${FFMPEG_ABIS_TO_BUILD[@]}
do
  source ${SCRIPTS_DIR}/export-build-variables.sh ${ABI}

  for COMPONENT in ${COMPONENTS_TO_BUILD[@]}
  do
    echo "Building the component: ${COMPONENT} for ${ABI}"
    COMPONENT_SOURCES_DIR_VARIABLE=SOURCES_DIR_${COMPONENT}

    cd ${!COMPONENT_SOURCES_DIR_VARIABLE}

    source ${SCRIPTS_DIR}/${COMPONENT}/build.sh || exit 1

    cd ${BASE_DIR}
  done

  checkTextRelocations || exit 1

  prepareOutput
done


echo "=========================================================="
echo "FFmpeg build completed successfully!"
echo "Output files for your Android apps are in: ${OUTPUT_DIR}"
echo "=========================================================="

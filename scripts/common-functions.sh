#!/usr/bin/env bash

function downloadTarArchive() {
  LIBRARY_NAME=$1
  DOWNLOAD_URL=$2
  NEED_EXTRA_DIRECTORY=$3

  ARCHIVE_NAME=${DOWNLOAD_URL##*/}
  LIBRARY_SOURCES="${ARCHIVE_NAME%.tar.*}"

  echo "Ensuring sources of ${LIBRARY_NAME} in ${LIBRARY_SOURCES}"

  if [[ ! -d "$LIBRARY_SOURCES" ]]; then
    curl -LO ${DOWNLOAD_URL}

    EXTRACTION_DIR="."
    if [ "$NEED_EXTRA_DIRECTORY" = true ] ; then
      EXTRACTION_DIR=${LIBRARY_SOURCES}
      mkdir -p ${EXTRACTION_DIR}
    fi

    if ! tar xf ${ARCHIVE_NAME} -C ${EXTRACTION_DIR} 2>/dev/null; then
      python3 -c "import tarfile, sys; tarfile.open(sys.argv[1]).extractall(sys.argv[2])" "${ARCHIVE_NAME}" "${EXTRACTION_DIR}" || exit 1
    fi
    rm -f ${ARCHIVE_NAME}
  fi

  export SOURCES_DIR_${LIBRARY_NAME}=$(pwd)/${LIBRARY_SOURCES}
}

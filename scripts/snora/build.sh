[ -z "${BASE_DIR}" ] && export BASE_DIR="/app/applet"
[ -z "${BUILD_DIR_FFMPEG}" ] && export BUILD_DIR_FFMPEG="${BASE_DIR}/build/ffmpeg"
[ -z "${BUILD_DIR_EXTERNAL}" ] && export BUILD_DIR_EXTERNAL="${BASE_DIR}/build/external"
[ -z "${INSTALL_DIR}" ] && export INSTALL_DIR="${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}"

FFMPEG_PREFIX="${BUILD_DIR_FFMPEG}/${ANDROID_ABI}"
EXTERNAL_PREFIX="${INSTALL_DIR}"

CROSS_FILE_NAME=crossfile-${ANDROID_ABI}.meson
rm -f ${CROSS_FILE_NAME}

cat > "${CROSS_FILE_NAME}" << EOF
[binaries]
c = '${FAM_CC}'
cpp = '${FAM_CXX}'
ar = '${FAM_AR}'
nm = '${FAM_NM}'
strip = '${FAM_STRIP}'
pkgconfig = '${PKG_CONFIG_EXECUTABLE}'
pkg-config = '${PKG_CONFIG_EXECUTABLE}'

[host_machine]
system = 'android'
cpu_family = '${CPU_FAMILY}'
cpu = '${TARGET_TRIPLE_MACHINE_ARCH}'
endian = 'little'

[built-in options]
prefix = '${EXTERNAL_PREFIX}'
c_args = ['-I${FFMPEG_PREFIX}/include', '-I${EXTERNAL_PREFIX}/include', '-fPIC']
cpp_args = ['-I${FFMPEG_PREFIX}/include', '-I${EXTERNAL_PREFIX}/include', '-fPIC']
c_link_args = ['-L${FFMPEG_PREFIX}/lib', '-L${EXTERNAL_PREFIX}/lib']
cpp_link_args = ['-L${FFMPEG_PREFIX}/lib', '-L${EXTERNAL_PREFIX}/lib']
pkg_config_path = ['${FFMPEG_PREFIX}/lib/pkgconfig', '${EXTERNAL_PREFIX}/lib/pkgconfig']
EOF

BUILD_DIRECTORY=build/${ANDROID_ABI}
rm -rf ${BUILD_DIRECTORY}

export PKG_CONFIG_PATH="${FFMPEG_PREFIX}/lib/pkgconfig:${EXTERNAL_PREFIX}/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="${FFMPEG_PREFIX}/lib/pkgconfig:${EXTERNAL_PREFIX}/lib/pkgconfig"

unset CC CXX

CORE_LIB_FLAG="-Dlibmpv=true"

${MESON_EXECUTABLE} setup ${BUILD_DIRECTORY} \
  --cross-file ${CROSS_FILE_NAME} \
  --default-library shared \
  ${CORE_LIB_FLAG} \
  -Dcplayer=false \
  -Dbuild-date=false \
  -Diconv=disabled \
  -Dlua=disabled \
  -Djavascript=disabled \
  -Dlibarchive=disabled \
  -Drubberband=disabled \
  -Duchardet=disabled \
  -Dzimg=disabled \
  -Dalsa=disabled \
  -Djack=disabled \
  -Dpulse=disabled \
  -Dpipewire=disabled \
  -Daaudio=disabled \
  -Dopensles=enabled \
  -Degl-android=enabled \
  -Dandroid-media-ndk=enabled \
  -Dplain-gl=enabled \
  -Dcdda=disabled \
  -Ddvdnav=disabled \
  -Dlibbluray=disabled

cd ${BUILD_DIRECTORY}

${NINJA_EXECUTABLE} -j ${HOST_NPROC}
${NINJA_EXECUTABLE} install

mkdir -p "${INSTALL_DIR}/lib"

SNORA_SO_FOUND=""
if [ -f "${INSTALL_DIR}/lib/libsnora.so" ]; then
  SNORA_SO_FOUND="${INSTALL_DIR}/lib/libsnora.so"
else
  SNORA_SO_FOUND=$(find "${INSTALL_DIR}" build . -type f -name "*.so" 2>/dev/null | grep -v "avcodec\|avformat\|avutil\|swresample\|swscale\|avfilter\|avdevice\|placebo" | head -n 1)
fi

if [ -n "${SNORA_SO_FOUND}" ]; then
  cp -f "${SNORA_SO_FOUND}" "${INSTALL_DIR}/lib/libsnora.so"
  find "${INSTALL_DIR}/lib" -maxdepth 1 -name "*.so" ! -name "libsnora.so" ! -name "libplacebo.so" ! -name "libav*.so" ! -name "libsw*.so" -delete 2>/dev/null || true
  rm -rf "${INSTALL_DIR}/lib/pkgconfig"
  if [ -d "${INSTALL_DIR}/include/mpv" ]; then
    mkdir -p "${INSTALL_DIR}/include/snora"
    cp -r "${INSTALL_DIR}/include/mpv/." "${INSTALL_DIR}/include/snora/"
    rm -rf "${INSTALL_DIR}/include/mpv"
  fi
  echo "==> Successfully compiled and installed libsnora.so for ${ANDROID_ABI} from ${SNORA_SO_FOUND}!"
else
  echo "ERROR: libsnora.so build failed or output library not found!"
  exit 1
fi

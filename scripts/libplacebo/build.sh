#!/usr/bin/env bash

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
prefix = '${INSTALL_DIR}'
c_args = ['-I${INSTALL_DIR}/include', '-fPIC']
cpp_args = ['-I${INSTALL_DIR}/include', '-fPIC']
c_link_args = ['-L${INSTALL_DIR}/lib']
cpp_link_args = ['-L${INSTALL_DIR}/lib']
EOF

BUILD_DIRECTORY=build/${ANDROID_ABI}
rm -rf ${BUILD_DIRECTORY}

unset CC CXX

${MESON_EXECUTABLE} setup ${BUILD_DIRECTORY} \
  --cross-file ${CROSS_FILE_NAME} \
  -Dvulkan=disabled \
  -Dopengl=disabled \
  -Ddemos=false

cd ${BUILD_DIRECTORY}

${NINJA_EXECUTABLE} -j ${HOST_NPROC}
${NINJA_EXECUTABLE} install

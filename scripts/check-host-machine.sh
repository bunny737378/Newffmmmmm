#!/usr/bin/env bash

if [[ -z "${ANDROID_SDK_HOME}" ]]; then
  if [[ -n "${ANDROID_SDK_ROOT}" ]]; then
    export ANDROID_SDK_HOME="${ANDROID_SDK_ROOT}"
  elif [[ -n "${ANDROID_HOME}" ]]; then
    export ANDROID_SDK_HOME="${ANDROID_HOME}"
  fi
fi

if [[ -z "${ANDROID_NDK_HOME}" ]]; then
  if [[ -n "${ANDROID_SDK_HOME}" && -d "${ANDROID_SDK_HOME}/ndk" ]]; then
    LATEST_NDK=$(ls -1 "${ANDROID_SDK_HOME}/ndk" 2>/dev/null | sort -V | tail -n 1)
    if [[ -n "${LATEST_NDK}" ]]; then
      export ANDROID_NDK_HOME="${ANDROID_SDK_HOME}/ndk/${LATEST_NDK}"
    fi
  elif [[ -n "${NDK_HOME}" ]]; then
    export ANDROID_NDK_HOME="${NDK_HOME}"
  elif [[ -n "${NDK}" ]]; then
    export ANDROID_NDK_HOME="${NDK}"
  fi
fi

function checkVariablePresence() {
  VARIABLE_NAME=$1
  if [[ -z "${!VARIABLE_NAME}" ]]; then
    echo "The ${VARIABLE_NAME} environment variable isn't defined"
    echo "$2"
    exit 1
  fi
}

checkVariablePresence "ANDROID_SDK_HOME" \
  "The variable should be set to the actual Android SDK path (or define ANDROID_HOME / ANDROID_SDK_ROOT)" || exit 1

checkVariablePresence "ANDROID_NDK_HOME" \
  "The variable should be set to the actual Android NDK path" || exit 1
